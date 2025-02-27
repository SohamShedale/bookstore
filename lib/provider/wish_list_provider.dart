import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WishListProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> addToWishList(Map<String, dynamic> book) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .doc(book["id"])
            .set({...book, "bookRef": book["id"]});
        _successMessage = "Book added to wishlist";
        notifyListeners();
      } else {
        _errorMessage = "Sign in required";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to add book in wishlist.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromWishList(String bookID) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .doc(bookID)
            .delete();
        _successMessage = "Book removed from wishlist";
        notifyListeners();
      } else {
        _errorMessage = "Sign in required";
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Failed to remove book from wishlist.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isFavourite(String bookID) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("wishlist")
            .where("bookRef", isEqualTo: bookID)
            .get();
        if (doc.docs.isNotEmpty) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> getWishList() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection("users")
          .doc(user.uid)
          .collection("wishlist")
          .snapshots();
    }
    return Stream.empty();
  }
}
