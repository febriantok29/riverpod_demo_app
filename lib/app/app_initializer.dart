import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_demo_app/app/pages/approval_page.dart';
import 'package:riverpod_demo_app/app/pages/home_page.dart';
import 'package:riverpod_demo_app/app/pages/login_page.dart';
import 'package:riverpod_demo_app/app/pages/splash_screen.dart';
import 'package:riverpod_demo_app/app/riverpod/providers/app_provider.dart';
import 'package:riverpod_demo_app/app/states/app_state.dart';

/// AppInitializer
/// Widget yang bertanggung jawab untuk:
/// 1. Trigger initialization logic
/// 2. Listen ke state changes
/// 3. Handle navigation ke route yang sesuai
///
/// Splash screen hanya render UI, semua logic ada di sini
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Trigger initialization setelah widget di-build
    Future.microtask(() {
      ref.read(AppProviders.notifier.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch app state untuk trigger rebuild saat state berubah
    ref.watch(AppProviders.notifier);

    // Listen untuk route changes dan navigate accordingly
    ref.listen(AppProviders.notifier, (previous, next) {
      if (!next.isInitializing && next.currentRoute != AppRoute.splash) {
        _navigateToRoute(context, next.currentRoute);
      }
    });

    // Selalu render splash screen, navigation akan di-handle oleh listener
    return const SplashScreen();
  }

  /// Navigate berdasarkan AppRoute
  void _navigateToRoute(BuildContext context, AppRoute route) {
    Widget destinationPage;

    switch (route) {
      case AppRoute.login:
        destinationPage = const LoginPage();
        break;
      case AppRoute.approval:
        destinationPage = const ApprovalPage();
        break;
      case AppRoute.home:
        destinationPage = const HomePage();
        break;
      case AppRoute.splash:
        return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => destinationPage));
  }
}
