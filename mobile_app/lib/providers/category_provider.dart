import 'package:flutter/foundation.dart';
import '../models/category.dart' as CategoryModel;
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getCategories();
      _categories = data.map<CategoryModel.Category>((json) => CategoryModel.Category.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CategoryModel.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
