import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProducts({
    int page = 1,
    int limit = 10,
    String? search,
    int? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? featured,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getProducts(
        page: page,
        limit: limit,
        search: search,
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        featured: featured,
      );

      if (response['success']) {
        final List<dynamic> productsJson = response['data']['items'];
        _products = productsJson.map((json) => Product.fromJson(json)).toList();
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

  Future<void> fetchFeaturedProducts() async {
    try {
      final response = await ApiService.getProducts(
        featured: true,
        limit: 10,
      );

      if (response['success']) {
        final List<dynamic> productsJson = response['data']['items'];
        _featuredProducts = productsJson.map((json) => Product.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching featured products: $e');
    }
  }

  Future<Product?> getProduct(int id) async {
    try {
      return await ApiService.getProduct(id);
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}