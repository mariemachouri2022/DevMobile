import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smartfit/models/membership.dart';
import 'package:smartfit/services/membership_service.dart';
import 'package:smartfit/providers/auth_provider.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  Membership? m;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Membership) {
      setState(() { m = args; loading = false; });
      return;
    }
    final user = context.read<AuthProvider>().currentUser!;
    final active = await MembershipService.instance.getActiveMembership(user.id!);
    setState(() { m = active; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (m == null) return const Scaffold(body: Center(child: Text('No active membership')));
    return Scaffold(
      appBar: AppBar(title: const Text('Membership QR')),
      body: Center(
        child: QrImageView(
          data: m!.qrCode ?? '',
          version: QrVersions.auto,
          size: 240,
        ),
      ),
    );
  }
}
