import 'package:bookstore/provider/auth_user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApiCallsProvider extends ChangeNotifier {
  final _fireStore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _userDetails;
  final List<Map<String, List<Map<String, dynamic>>>> _books = [];
  final Map<String, List<Map<String, dynamic>>> _cachedBooks = {};
  final int _booksCacheExpirationHours = 24;
  int _booksCacheTimestamp = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get userDetails => _userDetails;
  List<Map<String, List<Map<String, dynamic>>>> get books => _books;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> clearUserDetails() async {
    _userDetails = null;
    notifyListeners();
  }

  Future<void> syncUserDetails(BuildContext context) async {
    final authProvider = Provider.of<AuthUserProvider>(context, listen: false);

    if (_userDetails != null) {
      return;
    }

    if (authProvider.user == null) {
      await authProvider.initAuthState();
    }

    if (authProvider.user != null) {
      _userDetails = authProvider.user!.toJson();
      notifyListeners();
    }
  }

  Future<void> getBooksByCategory(String category) async {
    if (_cachedBooks.containsKey(category) && !_isCacheExpired()) {
      int existingCategoryIndex =
          _books.indexWhere((element) => element.containsKey(category));

      if (existingCategoryIndex != -1) {
        _books[existingCategoryIndex][category] = _cachedBooks[category]!;
      } else {
        _books.add({category: _cachedBooks[category]!});
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> categoryBooks = [];
      CollectionReference booksCollection = _fireStore.collection("books");
      DocumentReference categoryDoc = booksCollection.doc(category);
      CollectionReference books = categoryDoc.collection("books");
      QuerySnapshot booksSnapshot = await books.get();

      for (var book in booksSnapshot.docs) {
        final bookData = book.data() as Map<String, dynamic>;
        bookData["id"] = book.id;
        categoryBooks.add(bookData);
      }

      _cachedBooks[category] = categoryBooks;
      _booksCacheTimestamp = DateTime.now().millisecondsSinceEpoch;

      int existingCategoryIndex =
          _books.indexWhere((element) => element.containsKey(category));
      if (existingCategoryIndex != -1) {
        _books[existingCategoryIndex][category] = categoryBooks;
      } else {
        _books.add({category: categoryBooks});
      }
    } catch (e) {
      _errorMessage = "Failed to get books for $category: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        getBooksByCategory("comedy"),
        getBooksByCategory("fiction"),
        getBooksByCategory("history"),
        getBooksByCategory("love"),
        getBooksByCategory("tech"),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isCacheExpired() {
    if (_booksCacheTimestamp == 0) return true;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(_booksCacheTimestamp);
    final now = DateTime.now();
    final difference = now.difference(cacheTime).inHours;

    return difference > _booksCacheExpirationHours;
  }
}
