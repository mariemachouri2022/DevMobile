import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfit/providers/auth_provider.dart';
import 'package:smartfit/theme/app_theme.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;
  bool rememberMe = false;

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    final ok = await context.read<AuthProvider>().login(emailCtrl.text.trim(), passCtrl.text);
    setState(() { loading = false; });
    if (!ok && mounted) {
      setState(() { error = 'Invalid credentials'; });
    } else if (mounted) {
      final auth = context.read<AuthProvider>();
      Navigator.pushReplacementNamed(context, auth.isAdmin ? AppRouter.adminDashboard : AppRouter.memberHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('LOGIN', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/images/login_illustration.png',
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, size: 100, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: rememberMe, onChanged: (v) => setState(() => rememberMe = v ?? false)),
                  const Text('Remember me'),
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(loading ? 'Please wait...' : 'LOGIN', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary)),
                  TextButton(onPressed: () => Navigator.pushNamed(context, AppRouter.register), child: const Text('SIGN UP')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
