import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class DebugHelper {
  static Future<void> checkConnectivity() async {
    if (kDebugMode) {
      print('=== Debug: Checking connectivity ===');
      
      // Check if we can resolve the host
      try {
        final uri = Uri.parse(ApiConstants.baseUrl);
        final host = uri.host;
        final port = uri.port;
        
        print('Debug: Trying to connect to $host:$port');
        
        final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
        socket.destroy();
        print('Debug: Socket connection successful');
      } catch (e) {
        print('Debug: Socket connection failed: $e');
      }
      
      // Test API connection
      try {
        final result = await ApiService.testConnection();
        print('Debug: API test connection result: $result');
      } catch (e) {
        print('Debug: API test connection failed: $e');
      }
      
      print('=== Debug: Connectivity check complete ===');
    }
  }
  
  static void logError(String context, dynamic error) {
    if (kDebugMode) {
      print('Debug Error [$context]: $error');
    }
  }
  
  static void logInfo(String context, String message) {
    if (kDebugMode) {
      print('Debug Info [$context]: $message');
    }
  }
}
