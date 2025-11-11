import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smartfit/models/membership.dart';
import 'package:smartfit/models/payment.dart';
import 'package:smartfit/providers/auth_provider.dart';
import 'package:smartfit/services/payment_service.dart';
import 'package:smartfit/services/membership_service.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  Membership? membership;
  List<Payment> payments = [];
  bool loading = true;

  final amountCtrl = TextEditingController(text: '49.99'); // fallback manual
  String status = 'paid';
  String method = 'card';
  static const double pricePerMonth = 49.99;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().currentUser!;
      final m = await MembershipService.instance.getActiveMembership(user.id!);
      List<Payment> list = [];
      if (m != null) {
        list = await PaymentService.instance.listForMembership(m.id!);
      }
      if (mounted) {
        setState(() {
          membership = m;
          payments = list;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payments: $e')),
        );
      }
    }
  }

  Future<void> _addPayment() async {
    if (membership == null) return;
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    await PaymentService.instance.addPayment(
      membershipId: membership!.id!,
      amount: amount,
      status: status,
      method: method,
    );
    await _load();
  }

  Future<void> _renewAndPay() async {
    if (membership == null) return;
    final months = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _MonthsSheet(),
    );
    if (months == null) return;
    final amount = (months * pricePerMonth);
    final ok = await _cardCheckout(amount);
    if (!ok) return;
    final currentEnd = membership!.endDate.isAfter(DateTime.now()) ? membership!.endDate : DateTime.now();
    final newEnd = DateTime(currentEnd.year, currentEnd.month + months, currentEnd.day);
    await PaymentService.instance.addPayment(
      membershipId: membership!.id!,
      amount: amount,
      status: 'paid',
      method: 'card',
    );
    await MembershipService.instance.renew(membershipId: membership!.id!, newEndDate: newEnd);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Renewed $months mo • Paid ${amount.toStringAsFixed(2)}')));
  }

  Future<bool> _cardCheckout(double amount) async {
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pay ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(controller: numberCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Card number (16 digits)', prefixIcon: Icon(Icons.credit_card))),
              const SizedBox(height: 8),
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Name on card', prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: expCtrl, keyboardType: TextInputType.datetime, decoration: const InputDecoration(hintText: 'MM/YY'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: cvvCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'CVV'))),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(onPressed: () {
                  final ok = numberCtrl.text.replaceAll(' ', '').length >= 16 &&
                      nameCtrl.text.trim().isNotEmpty &&
                      RegExp(r'^\d{2}/\d{2}$').hasMatch(expCtrl.text) &&
                      cvvCtrl.text.length >= 3;
                  Navigator.pop(context, ok);
                }, child: const Text('Pay now')),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (membership == null) return const Scaffold(body: Center(child: Text('No active membership')));
    final df = DateFormat('yMMMd • HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active membership', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('Ends on: ${DateFormat('yMMMd').format(membership!.endDate)}'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _renewAndPay, child: const Text('Renew & Pay')),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) {
                  final p = payments[i];
                  final isPaid = p.status == 'paid';
                  return ListTile(
                    leading: Icon(isPaid ? Icons.receipt_long : Icons.schedule, color: isPaid ? Colors.green : Colors.orange),
                    title: Text('€${p.amount.toStringAsFixed(2)}'),
                    subtitle: Text('${df.format(p.date)} • ${p.method ?? '-'}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(p.status.toUpperCase(), style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: payments.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthsSheet extends StatelessWidget {
  final List<int> options = const [1, 3, 6, 12];
  _MonthsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Choose duration', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: options.map((m) => ChoiceChip(
            label: Text('$m mo'),
            selected: false,
            onSelected: (_) => Navigator.pop(context, m),
          )).toList()),
        ],
      ),
    );
  }
}
