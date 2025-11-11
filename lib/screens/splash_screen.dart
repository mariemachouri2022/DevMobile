import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router.dart';
import '../../state/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (auth.bootstrapped) {
      _route(auth);
    } else {
      auth.addListener(_listener);
    }
  }

  void _listener() {
    final auth = context.read<AuthProvider>();
    if (auth.bootstrapped) {
      auth.removeListener(_listener);
      _route(auth);
    }
  }

  void _route(AuthProvider auth) {
    if (!mounted) return;
    if (auth.isLoggedIn) {
      Navigator.pushReplacementNamed(context, auth.isAdmin ? AppRouter.adminDashboard : AppRouter.memberHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
