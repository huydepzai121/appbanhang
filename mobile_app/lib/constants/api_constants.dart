class ApiConstants {
  // Configure this based on your testing environment:
  // - Android Emulator: 'http://10.0.2.2:3000/api' (if 10.0.2.2 works)
  // - iOS Simulator: 'http://localhost:3000/api' or 'http://127.0.0.1:3000/api'
  // - Real Device: 'http://YOUR_COMPUTER_IP:3000/api' (e.g., 'http://192.168.1.100:3000/api')
  static const String baseUrl = 'http://192.168.1.59:3000/api';

  // Alternative URLs for different environments (uncomment as needed):
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator (if working)
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
  // static const String baseUrl = 'http://127.0.0.1:3000/api'; // Loopback

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String profile = '$baseUrl/auth/profile';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String verifyToken = '$baseUrl/auth/verify';

  // Products endpoints
  static const String products = '$baseUrl/products';

  // Categories endpoints
  static const String categories = '$baseUrl/categories';

  // Cart endpoints
  static const String cart = '$baseUrl/cart';
  static const String addToCart = '$baseUrl/cart/add';
  static String cartItem(int id) => '$baseUrl/cart/$id';

  static String get baseOrigin => baseUrl.replaceFirst('/api', '');

  // Orders endpoints
  static const String orders = '$baseUrl/orders';

  // Reviews endpoints
  static const String reviews = '$baseUrl/reviews';

  // Users endpoints (Admin)
  static const String users = '$baseUrl/users';

  // Admin endpoints
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminOrders = '$baseUrl/admin/orders';
  static const String adminUsers = '$baseUrl/admin/users';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
