import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/membership_service.dart';
import '../services/attendance_service.dart';
import '../providers/auth_provider.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool handled = false;

  Future<void> _handleCode(String? code) async {
    if (handled || code == null || code.isEmpty) return;
    handled = true;
    final membership = await MembershipService.instance.getByQr(code);
    if (!mounted) return;
    if (membership == null || !membership.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid or inactive membership')));
      Navigator.pop(context);
      return;
    }
    // Mark attendance for the membership owner
    await AttendanceService.instance.markAttendance(userId: membership.userId, viaQr: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance recorded')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().currentUser?.role == UserRole.admin;
    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'Scan Member QR' : 'Scan')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            _handleCode(barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}
