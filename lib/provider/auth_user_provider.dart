import 'dart:io';
import 'dart:convert';
import 'package:bookstore/common/constants/constants.dart';
import 'package:bookstore/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

class AuthUserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get user => _user;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> initAuthState() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final cachedUser = await getCachedUser();
      if (cachedUser != null) {
        _user = cachedUser;
        notifyListeners();
        _refreshUserData(currentUser.uid);
      } else {
        await _fetchUserFromFirestore(currentUser.uid);
      }
    }
  }

  Future<bool> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        final UserModel userModel =
            UserModel(uid: user.uid, name: name, email: email);
        await _storeUserInFirestore(userModel);
        await _cacheUserData(userModel);
        _user = userModel;
        _successMessage = "Account created successfully.";
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.code == "email-already-in-use"
          ? "Email already in use. Try to log in."
          : "Signup error. Try again.";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        await _fetchUserFromFirestore(user.uid);
        _successMessage = "Sign-in successful.";
        notifyListeners();
        return _user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = "Invalid email or password. $e";
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          await _fetchUserFromFirestore(user.uid);
          _successMessage = "Sign-in successful.";
          notifyListeners();
          return _user;
        }
      }
      return null;
    } catch (e) {
      _errorMessage = "Google Sign-in error. Try again.";
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await clearCache();
      _user = null;
      _successMessage = "Signed out successfully.";
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to sign out. Try again.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserFromFirestore(String uid) async {
    try {
      final docRef = _firestore.collection("users").doc(uid);
      final docSnapShot = await docRef.get();

      UserModel userModel;
      if (docSnapShot.exists) {
        userModel = UserModel.fromFirestore(docSnapShot);
      } else {
        // Create basic user if not found in Firestore
        final firebaseUser = _auth.currentUser!;
        userModel = UserModel.fromFirebaseUser(firebaseUser);
        await _storeUserInFirestore(userModel);
      }

      await _cacheUserData(userModel);
      _user = userModel;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error fetching user data.";
      notifyListeners();
    }
  }

  Future<void> _refreshUserData(String uid) async {
    try {
      final docRef = _firestore.collection("users").doc(uid);
      final docSnapShot = await docRef.get();

      if (docSnapShot.exists) {
        final userModel = UserModel.fromFirestore(docSnapShot);
        await _cacheUserData(userModel);
        _user = userModel;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Background refresh failed: $e";
      notifyListeners();
    }
  }

  Future<void> _cacheUserData(UserModel user) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/$userCacheFileName");

      final cachedUser = user.copyWith(
        name: user.name.isNotEmpty ? user.name : "Unknown",
        email: user.email.isNotEmpty ? user.email : "",
        photoURL: user.photoURL != null && user.photoURL!.isNotEmpty
            ? user.photoURL
            : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
      );

      final cacheData = cachedUser.toJson();
      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      _errorMessage = "Error caching user data.";
      notifyListeners();
    }
  }

  Future<UserModel?> getCachedUser() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/$userCacheFileName");

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          final decodedJson = jsonDecode(jsonString);

          if (decodedJson is Map<String, dynamic>) {
            UserModel user = UserModel.fromJson(decodedJson);
            _user = user;
            notifyListeners();

            return user;
          }
        }
      }
      return null;
    } catch (e) {
      _errorMessage = "Error retrieving cached user: $e";
      notifyListeners();
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/$userCacheFileName");
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _errorMessage = "Error clearing cache.";
      notifyListeners();
    }
  }

  Future<void> _storeUserInFirestore(UserModel user) async {
    try {
      final userRef = _firestore.collection("users").doc(user.uid);
      await userRef.set(user.toFirestore());
    } catch (e) {
      _errorMessage = "Error storing user data.";
      notifyListeners();
    }
  }
}
  // Future<void> add() async {
  //   CollectionReference books = _firestore.collection("books");
  //   CollectionReference category = books.doc("comedy").collection("books");
  //   String url =
  //       "https://www.googleapis.com/books/v1/volumes?q=subject:comedy&filter=paid-ebooks";
  //   final data = await http.get(Uri.parse(url));
  //   final dataString = jsonDecode(data.body);

  //   for (var item in dataString["items"]) {
  //     final volumeInfo = item["volumeInfo"];
  //     final saleInfo = item["saleInfo"];
  //     final imageLinks = volumeInfo["imageLinks"];

  //     Map<String, dynamic> bookData = {
  //       "title": volumeInfo["title"],
  //       "publisher": volumeInfo["publisher"],
  //       "publishedDate": volumeInfo["publishedDate"],
  //       "description": volumeInfo["description"],
  //     };

  //     if (volumeInfo["authors"] != null) {
  //       bookData["authors"] = List<String>.from(volumeInfo["authors"]);
  //     }

  //     if (volumeInfo["categories"] != null) {
  //       bookData["categories"] = List<String>.from(volumeInfo["categories"]);
  //     }

  //     if (imageLinks != null && imageLinks["smallThumbnail"] != null) {
  //       bookData["imageLinks"] = {
  //         "smallThumbnail": imageLinks["smallThumbnail"],
  //         "thumbnail": imageLinks["thumbnail"], // Add thumbnail conditionally
  //       };
  //     }

  //     if (saleInfo != null && saleInfo["listPrice"] != null) {
  //       final listPrice = saleInfo["listPrice"];
  //       if (listPrice["amount"] != null && listPrice["currencyCode"] != null) {
  //         bookData["saleInfo"] = {
  //           "amount": listPrice["amount"],
  //           "currencyCode": listPrice["currencyCode"],
  //         };
  //       }
  //       if (saleInfo["buyLink"] != null) {
  //         bookData["buyLink"] = saleInfo["buyLink"];
  //       }
  //     }
  //     await category.add(bookData);
  //   }
  // }