import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing connection from emulator to localhost...');
  
  // Test different URLs that might work from Android emulator
  final testUrls = [
    'http://10.0.2.2:3000/api/health',  // Android emulator
    'http://localhost:3000/api/health', // Direct localhost
    'http://127.0.0.1:3000/api/health', // Loopback
    'http://192.168.1.59:3000/api/health', // Real IP address
  ];
  
  for (final url in testUrls) {
    print('\nTesting: $url');
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Status: ${response.statusCode}');
      print('Response: $responseBody');
      
      client.close();
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS: $url is reachable');
      } else {
        print('⚠️  WARNING: $url returned status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $url failed - $e');
    }
  }
  
  print('\nConnection test complete.');
}
