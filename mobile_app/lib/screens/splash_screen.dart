import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Give some time for the splash screen to show
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Wait a bit more for auth provider to load from storage
      int attempts = 0;
      while (attempts < 10 && !authProvider.isAuthenticated && authProvider.token == null) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }

      if (mounted) {
        if (authProvider.isAuthenticated) {
          // Check if user is admin
          if (authProvider.isAdmin) {
            Navigator.of(context).pushReplacementNamed('/admin');
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Phone Store',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cửa hàng điện thoại uy tín',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}