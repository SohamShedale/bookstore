import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<Map<String, dynamic>> _myCartItems = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Map<String, dynamic>> get myCartItems => _myCartItems;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> getCartItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("myCart")
            .get();
        _myCartItems = snapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
          };
        }).toList();
      }
    } catch (e) {
      _errorMessage = "Failed to load cart items";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItemToCart(Map<String, dynamic> book, int quantity) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final document = _firestore
            .collection("users")
            .doc(user.uid)
            .collection("myCart")
            .doc(book["id"]);
        final bookData = await document.get();
        if (bookData.data() == null) {
          await document.set({
            ...book,
            "quantity": 1,
          });
          _myCartItems.add({...book, "quantity": 1});
          _successMessage = "Item added to cart";
        } else {
          final data = bookData.data() as Map<String, dynamic>;
          await document.set({
            ...data,
            "quantity": data["quantity"] + 1,
          });
          final index = _myCartItems.indexWhere(
            (item) => item["id"] == book["id"],
          );
          if (index != -1) {
            _myCartItems[index]["quantity"] += 1;
          }
          _successMessage = "Quantity increased";
        }
      }
    } catch (e) {
      _errorMessage = "Failed to add item to the cart $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeItemFromCart(String bookID, int quantity) async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final document = _firestore
            .collection("users")
            .doc(user.uid)
            .collection("myCart")
            .doc(bookID);
        final bookData = await document.get();
        final data = bookData.data() as Map<String, dynamic>;
        if (data["quantity"] > 1) {
          await document.set({
            ...data,
            "quantity": data["quantity"] - 1,
          });
          final index = _myCartItems.indexWhere((item) => item["id"] == bookID);
          if (index != -1) {
            _myCartItems[index]["quantity"] -= 1;
          }
          _successMessage = "Item removed from cart";
        } else if (data["quantity"] == 1) {
          await document.delete();
          _myCartItems.removeWhere((item) => item["id"] == bookID);
          _successMessage = "Item removed from cart";
        }
      }
    } catch (e) {
      _errorMessage = "Failed to remove item from cart";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
