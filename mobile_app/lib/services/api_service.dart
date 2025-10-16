import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  // Test connection to the server
  static Future<bool> testConnection() async {
    try {
      print('Debug: Testing connection to ${ApiConstants.baseUrl}');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl.replaceAll('/api', '')}/api/auth/verify'),
        headers: ApiConstants.headers,
      ).timeout(const Duration(seconds: 10));

      print('Debug: Connection test response: ${response.statusCode}');
      return response.statusCode == 401; // 401 is expected without token
    } catch (e) {
      print('Debug: Connection test failed: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    try {
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        String errorMessage = data['message'] ?? 'API Error';
        if (response.statusCode == 401) {
          errorMessage = 'Unauthorized - Please login again';
        } else if (response.statusCode == 404) {
          errorMessage = 'Resource not found';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error - Please try again later';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      }
      rethrow;
    }
  }

  // Auth methods
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: ApiConstants.headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: ApiConstants.headers,
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      }),
    );

    return _handleResponse(response);
  }

  static Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: ApiConstants.headersWithAuth(token),
    ).timeout(const Duration(seconds: 10));

    final data = await _handleResponse(response);
    return User.fromJson(data['data']);
  }

  // Products methods
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    int? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    String sortBy = 'created_at',
    String sortOrder = 'DESC',
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (category != null) {
      queryParams['category'] = category.toString();
    }
    if (brand != null && brand.isNotEmpty) {
      queryParams['brand'] = brand;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }
    if (featured != null) {
      queryParams['featured'] = featured.toString();
    }

    final uri = Uri.parse(ApiConstants.products).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: ApiConstants.headers)
        .timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  static Future<Product> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.products}/$id'),
      headers: ApiConstants.headers,
    );

    final data = await _handleResponse(response);
    return Product.fromJson(data['data']);
  }

  // Cart methods
  static Future<Map<String, dynamic>> getCart(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.cart),
      headers: ApiConstants.headersWithAuth(token),
    ).timeout(const Duration(seconds: 10));

    return _handleResponse(response);
  }

  static Future<void> addToCart(String token, int productId, int quantity) async {
    final response = await http.post(
      Uri.parse(ApiConstants.addToCart),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
      }),
    ).timeout(const Duration(seconds: 10));

    await _handleResponse(response);
  }

  static Future<void> updateCartItem(String token, int cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse(ApiConstants.cartItem(cartItemId)),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode({'quantity': quantity}),
    ).timeout(const Duration(seconds: 10));

    await _handleResponse(response);
  }

  static Future<void> removeCartItem(String token, int cartItemId) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.cartItem(cartItemId)),
      headers: ApiConstants.headersWithAuth(token),
    ).timeout(const Duration(seconds: 10));

    await _handleResponse(response);
  }

  static Future<void> clearCart(String token) async {
    final response = await http.delete(
      Uri.parse(ApiConstants.cart),
      headers: ApiConstants.headersWithAuth(token),
    ).timeout(const Duration(seconds: 10));

    await _handleResponse(response);
  }

  // Orders methods
  static Future<Map<String, dynamic>> createOrder(
    String token,
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.orders),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(orderData),
    );

    return _handleResponse(response);
  }

  static Future<List<dynamic>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.orders),
      headers: ApiConstants.headersWithAuth(token),
    );

    final data = await _handleResponse(response);
    return data['data'];
  }

  // Admin methods
  static Future<Map<String, dynamic>> createProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.products),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(productData),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> productData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.products}/$productId'),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(productData),
    );

    return _handleResponse(response);
  }

  static Future<void> deleteProduct(String token, int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.products}/$productId'),
      headers: ApiConstants.headersWithAuth(token),
    );

    await _handleResponse(response);
  }

  static Future<List<dynamic>> getAllUsers(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.users),
      headers: ApiConstants.headersWithAuth(token),
    );

    final data = await _handleResponse(response);
    return data['data'];
  }

  static Future<Map<String, dynamic>> getUserById(String token, int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.users}/$userId'),
      headers: ApiConstants.headersWithAuth(token),
    );

    return _handleResponse(response);
  }

  static Future<List<dynamic>> getAllOrders(String token) async {
    try {
      print('Debug: Making request to ${ApiConstants.adminOrders}');
      print('Debug: Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(ApiConstants.adminOrders),
        headers: ApiConstants.headersWithAuth(token),
      );

      print('Debug: Response status: ${response.statusCode}');
      print('Debug: Response body: ${response.body}');

      final data = await _handleResponse(response);

      if (data['data'] == null || data['data']['orders'] == null) {
        throw Exception('Invalid response structure: ${data.toString()}');
      }

      return data['data']['orders'];
    } catch (e) {
      print('Debug: getAllOrders error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String token,
    int orderId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminOrders}/$orderId/status'),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode({'status': status}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getDashboardStats(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminDashboard),
      headers: ApiConstants.headersWithAuth(token),
    );

    return _handleResponse(response);
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse(ApiConstants.categories),
      headers: ApiConstants.headers,
    );

    final data = await _handleResponse(response);
    return data['data'];
  }

  static Future<Map<String, dynamic>> createCategory(
    String token,
    Map<String, dynamic> categoryData,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.categories),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(categoryData),
    );

    return _handleResponse(response);
  }

  // Admin create order
  static Future<Map<String, dynamic>> createOrderForAdmin(
    String token,
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConstants.adminOrders),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(orderData),
    );

    return _handleResponse(response);
  }

  // Admin update user
  static Future<Map<String, dynamic>> updateUser(
    String token,
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.adminUsers}/$userId'),
      headers: ApiConstants.headersWithAuth(token),
      body: json.encode(userData),
    );

    return _handleResponse(response);
  }

  // Admin delete user
  static Future<void> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.adminUsers}/$userId'),
      headers: ApiConstants.headersWithAuth(token),
    );

    await _handleResponse(response);
  }
}
