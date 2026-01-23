import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/pages/home_page.dart';
import 'package:riverpod_demo_app/app/pages/login_page.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay eksekusi sampai widget tree selesai building
    Future.microtask(() => _checkAuthStatus());
  }

  Future<void> _checkAuthStatus() async {
    // Check auth status
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    // Delay untuk efek splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate berdasarkan auth status
    final authState = ref.read(authNotifierProvider);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            authState.isAuthenticated ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Riverpod Demo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
