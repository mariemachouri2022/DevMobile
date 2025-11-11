// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/cart_provider.dart';
// import '../services/payment_service.dart';
//
// class PaymentScreen extends StatelessWidget {
//   final double totalAmount;
//
//   const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Text('Paiement - PROJET ACADÉMIQUE'),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Bannière projet académique
//             _buildAcademicBanner(),
//             SizedBox(height: 10),
//
//             // En-tête du paiement
//             Container(
//               padding: EdgeInsets.all(20),
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Icon(Icons.school, color: Colors.orange),
//                   SizedBox(width: 12),
//                   Text('Montant du projet'),
//                   Spacer(),
//                   Text(
//                     '${totalAmount.toStringAsFixed(2)} €',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//
//             // Instructions pour cartes de test
//             _buildTestCardInstructions(),
//             SizedBox(height: 20),
//
//             // Bouton de paiement
//             Padding(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.credit_card,
//                     size: 80,
//                     color: Colors.orange,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'DÉMONSTRATION DE PAIEMENT',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Ceci est une simulation pour projet académique\nAucun vrai argent n\'est débité',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                   SizedBox(height: 30),
//                   _buildPaymentButton(context),
//                   SizedBox(height: 20),
//                   _buildTestButtons(context),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAcademicBanner() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(12),
//       color: Colors.orange,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.school, color: Colors.white, size: 20),
//           SizedBox(width: 8),
//           Text(
//             'PROJET ACADÉMIQUE - MODE DÉMONSTRATION',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTestCardInstructions() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xFFE8F5E8),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.green),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.credit_card, color: Colors.green),
//                 SizedBox(width: 8),
//                 Text(
//                   'CARTES DE TEST STRIPE',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             _buildTestCardItem('4242 4242 4242 4242', '✅ Paiement réussi'),
//             _buildTestCardItem('4000 0000 0000 0002', '❌ Paiement refusé'),
//             _buildTestCardItem('4000 0000 0000 0069', '⚠️ Carte expirée'),
//             SizedBox(height: 8),
//             Text(
//               'Date: 12/34 - CVC: 123 - Code postal: 75001',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.green[800],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTestCardItem(String number, String description) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               '$number - $description',
//               style: TextStyle(fontSize: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton(
//         onPressed: () => _processPayment(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.orange,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 2,
//         ),
//         child: Text(
//           'TESTER LE PAIEMENT ${totalAmount.toStringAsFixed(2)} €',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTestButtons(BuildContext context) {
//     return Column(
//       children: [
//         Divider(),
//         SizedBox(height: 10),
//         Text(
//           'Tests rapides:',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
//         ),
//         SizedBox(height: 10),
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _testSmallAmount(context),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.orange,
//                   side: BorderSide(color: Colors.orange),
//                 ),
//                 child: Text('Test 1€'),
//               ),
//             ),
//             SizedBox(width: 10),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () => _processPayment(context),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.orange,
//                   side: BorderSide(color: Colors.orange),
//                 ),
//                 child: Text('Test ${totalAmount.toStringAsFixed(2)}€'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void _testSmallAmount(BuildContext context) async {
//     _showLoading(context, 'Test de paiement 1€...');
//
//     try {
//       await PaymentService.processPayment(
//         amount: 1.0,
//         currency: 'EUR',
//       );
//
//       Navigator.of(context).pop();
//       _showSuccessDialog(context, 'Test de paiement réussi !\nAucun argent réel n\'a été débité.');
//     } catch (e) {
//       Navigator.of(context).pop();
//       _showErrorDialog(context, e.toString());
//     }
//   }
//
//   void _processPayment(BuildContext context) async {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//
//     _showLoading(context, 'Simulation de paiement...');
//
//     try {
//       await PaymentService.processPayment(
//         amount: totalAmount,
//         currency: 'EUR',
//       );
//
//       Navigator.of(context).pop();
//       _showPaymentSuccess(context, cartProvider);
//
//     } catch (e) {
//       Navigator.of(context).pop();
//       _showErrorDialog(context, e.toString());
//     }
//   }
//
//   void _showLoading(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(color: Colors.orange),
//               SizedBox(height: 16),
//               Text(
//                 message,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Projet académique - Mode test',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showPaymentSuccess(BuildContext context, CartProvider cartProvider) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green, size: 24),
//             SizedBox(width: 8),
//             Text(
//               'DÉMONSTRATION RÉUSSIE !',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Simulation de paiement réussie pour ${totalAmount.toStringAsFixed(2)} €.'),
//             SizedBox(height: 10),
//             Text(
//               '💡 Ceci est une démonstration académique\nAucun paiement réel n\'a été effectué',
//               style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               cartProvider.clearCart();
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//             child: Text(
//               'Retour à la boutique',
//               style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSuccessDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.green),
//             SizedBox(width: 8),
//             Text('Démonstration réussie'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK', style: TextStyle(color: Colors.orange)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showErrorDialog(BuildContext context, String error) {
//     String errorMessage = error.contains('Exception:')
//         ? error.split('Exception:').last.trim()
//         : error;
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.error_outline, color: Colors.red, size: 24),
//             SizedBox(width: 8),
//             Text(
//               'Erreur de démonstration',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//             ),
//           ],
//         ),
//         content: Text(_formatErrorMessage(errorMessage)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('OK', style: TextStyle(color: Colors.orange)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatErrorMessage(String error) {
//     if (error.contains('Annulé')) return 'Démonstration annulée.';
//     if (error.contains('card_declined')) return 'Carte refusée (comportement de test).';
//     if (error.contains('expired_card')) return 'Carte expirée (comportement de test).';
//     return error.length > 150 ? '${error.substring(0, 150)}...' : error;
//   }
// }









import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/payment_service.dart'; // Import du service externe

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();
  bool _isProcessing = false;

  // Couleurs du thème carte (bleu/orange)
  final Color _primaryColor = const Color(0xFF1E88E5); // Bleu principal
  final Color _accentColor = const Color(0xFFFF9800);  // Orange accent
  final Color _backgroundColor = const Color(0xFFF5F5F5); // Gris clair
  final Color _cardColor = const Color(0xFFFFFFFF); // Blanc
  final Color _textColor = const Color(0xFF333333); // Texte foncé

  @override
  void initState() {
    super.initState();
    _initializeStripe();

    // Pré-remplir avec une carte de test pour faciliter les tests
    _cardNumberController.text = '4242424242424242';
    _expMonthController.text = '12';
    _expYearController.text = '34';
    _cvcController.text = '123';
  }

  Future<void> _initializeStripe() async {
    await PaymentService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Paiement Sécurisé',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec montant
            _buildAmountHeader(),
            const SizedBox(height: 24),

            // Formulaire de carte
            _buildCardForm(),
            const SizedBox(height: 24),

            // Instructions pour cartes de test
            _buildTestCardSection(),
            const SizedBox(height: 24),

            // Bouton de paiement
            _buildPaymentButton(),
            const SizedBox(height: 16),

            // Sécurité et garanties
            _buildSecuritySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total à payer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.totalAmount.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Paiement 100% sécurisé - Mode démonstration',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: _primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Informations de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Numéro de carte
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Numéro de carte',
              labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor, width: 2),
              ),
              prefixIcon: Icon(Icons.credit_card, color: _primaryColor),
              hintText: '4242 4242 4242 4242',
              filled: true,
              fillColor: _backgroundColor,
            ),
            keyboardType: TextInputType.number,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Date d'expiration et CVC
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expMonthController,
                  decoration: InputDecoration(
                    labelText: 'Mois',
                    labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    hintText: 'MM',
                    filled: true,
                    fillColor: _backgroundColor,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expYearController,
                  decoration: InputDecoration(
                    labelText: 'Année',
                    labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    hintText: 'AA',
                    filled: true,
                    fillColor: _backgroundColor,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cvcController,
                  decoration: InputDecoration(
                    labelText: 'CVC',
                    labelStyle: TextStyle(color: _textColor.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: _primaryColor, width: 2),
                    ),
                    hintText: '123',
                    filled: true,
                    fillColor: _backgroundColor,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Les informations de votre carte sont cryptées et sécurisées',
            style: TextStyle(
              fontSize: 12,
              color: _textColor.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'CARTES DE TEST STRIPE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTestCardRow('4242 4242 4242 4242', 'Paiement réussi', Icons.check_circle, Colors.green),
          _buildTestCardRow('4000 0000 0000 0002', 'Paiement refusé', Icons.cancel, Colors.red),
          _buildTestCardRow('4000 0000 0000 0069', 'Carte expirée', Icons.warning, Colors.orange),
          const SizedBox(height: 8),
          Text(
            'Utilisez 12/34 pour la date et 123 pour le CVC',
            style: TextStyle(
              fontSize: 12,
              color: _primaryColor.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCardRow(String number, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$number - $description',
              style: TextStyle(
                fontSize: 12,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isProcessing
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Traitement en cours...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 20),
            const SizedBox(width: 8),
            Text(
              'PAYER ${widget.totalAmount.toStringAsFixed(2)} €',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildSecurityItem(Icons.security, 'Paiement sécurisé'),
        _buildSecurityItem(Icons.lock, 'Cryptage SSL'),
        _buildSecurityItem(Icons.verified_user, 'Garantie'),
      ],
    );
  }

  Widget _buildSecurityItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: _textColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expMonthController.text.isEmpty ||
        _expYearController.text.isEmpty ||
        _cvcController.text.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs de la carte');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Utiliser le PaymentService du fichier externe
      await PaymentService.processPayment(
        amount: widget.totalAmount,
        currency: 'EUR',
      );

      _showPaymentSuccess();

    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showPaymentSuccess() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                'Paiement Réussi !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Votre paiement de ${widget.totalAmount.toStringAsFixed(2)} € a été traité avec succès.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cartProvider.clearCart();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Retour à la boutique',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    String errorMessage = error.contains('Exception:')
        ? error.split('Exception:').last.trim()
        : error;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              'Erreur de paiement',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(_formatErrorMessage(errorMessage)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatErrorMessage(String error) {
    if (error.contains('Annulé')) return 'Paiement annulé.';
    if (error.contains('card_declined')) return 'Carte refusée. Veuillez utiliser une autre carte.';
    if (error.contains('expired_card')) return 'Carte expirée. Veuillez vérifier la date.';
    return error.length > 150 ? '${error.substring(0, 150)}...' : error;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cvcController.dispose();
    super.dispose();
  }
}
