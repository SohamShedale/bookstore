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

  final Map<String, List<Map<String, dynamic>>> _homePageBooks = {};
  final Map<String, List<Map<String, dynamic>>> _allBooks = {};
  final Map<String, DocumentSnapshot?> _lastDocuments = {};
  final int _pageSize = 5;

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

  bool hasMoreBooks(String category) {
    return _lastDocuments[category] != null;
  }

  Future<void> getHomePageBooks() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        getBooksByCategory("comedy", limit: 5),
        getBooksByCategory("fiction", limit: 5),
        getBooksByCategory("history", limit: 5),
        getBooksByCategory("love", limit: 5),
        getBooksByCategory("tech", limit: 5),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> getBooksByCategory(String category,
      {int? limit, bool loadMore = false}) async {
    try {
      CollectionReference booksCollection = _fireStore.collection("books");
      DocumentReference categoryDoc = booksCollection.doc(category);
      CollectionReference books = categoryDoc.collection("books");

      Query query = books.orderBy('title');
      if (loadMore && _lastDocuments.containsKey(category)) {
        query = query.startAfterDocument(_lastDocuments[category]!);
      }

      QuerySnapshot booksSnapshot = await query.limit(limit ?? _pageSize).get();

      List<Map<String, dynamic>> newBooks = [];
      for (var book in booksSnapshot.docs) {
        final bookData = book.data() as Map<String, dynamic>;
        bookData["id"] = book.id;
        newBooks.add(bookData);
      }

      if (booksSnapshot.docs.isNotEmpty) {
        _lastDocuments[category] = booksSnapshot.docs.last;
      }

      if (loadMore) {
        _allBooks[category]?.addAll(newBooks);
      } else {
        if (limit == 5) {
          _homePageBooks[category] = newBooks;
        } else {
          _allBooks[category] = newBooks;
        }
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to get books for $category: $e";
      notifyListeners();
    }
  }

  Future<void> loadMoreBooks(String category) async {
    await getBooksByCategory(category, loadMore: true);
  }

  List<Map<String, dynamic>> getHomePageCategoryBooks(String category) {
    return _homePageBooks[category] ?? [];
  }

  List<Map<String, dynamic>> getAllCategoryBooks(String category) {
    return _allBooks[category] ?? [];
  }
}
