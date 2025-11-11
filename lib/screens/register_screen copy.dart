import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/router.dart';
import '../../state/auth_provider.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String role = 'member';
  bool loading = false;

  Future<void> _submit() async {
    setState(() { loading = true; });
    await context.read<AuthProvider>().register(nameCtrl.text.trim(), emailCtrl.text.trim(), passCtrl.text, role: role);
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.pushNamedAndRemoveUntil(context, auth.isAdmin ? AppRouter.adminDashboard : AppRouter.memberHome, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Member')),
                DropdownMenuItem(value: 'admin', child: Text('Administrator')),
              ],
              onChanged: (v) => setState(() => role = v ?? 'member'),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: loading ? 'Please wait...' : 'Create account', onPressed: loading ? (){} : _submit),
          ],
        ),
      ),
    );
  }
}
