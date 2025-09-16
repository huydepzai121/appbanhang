import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _cartItems = [];
  double _total = 0.0;
  int _itemCount = 0;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get cartItems => _cartItems;
  double get total => _total;
  int get itemCount => _itemCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCart(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getCart(token);

      if (response['success']) {
        _cartItems = response['data']['items'];
        _total = double.parse(response['data']['total'].toString());
        _itemCount = response['data']['count'];
      } else {
        _error = response['message'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(String token, int productId, int quantity) async {
    try {
      await ApiService.addToCart(token, productId, quantity);
      await fetchCart(token); // Refresh cart
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCart() {
    _cartItems = [];
    _total = 0.0;
    _itemCount = 0;
    notifyListeners();
  }
}