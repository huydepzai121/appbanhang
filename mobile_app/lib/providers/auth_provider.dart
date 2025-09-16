import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userJson = prefs.getString('user');

      if (_token != null && userJson != null) {
        // Verify token is still valid
        try {
          _user = await ApiService.getProfile(_token!);
          notifyListeners();
        } catch (e) {
          // Token expired or invalid, clear storage
          await _clearStorage();
        }
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  Future<void> _saveUserToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null && _user != null) {
        await prefs.setString('token', _token!);
        await prefs.setString('user', _user!.toJson().toString());
      }
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      _token = null;
      _user = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.login(email, password);

      if (response['success']) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);
        await _saveUserToStorage();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      if (response['success']) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);
        await _saveUserToStorage();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _clearStorage();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}