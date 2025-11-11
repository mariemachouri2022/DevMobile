// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class PaymentService {
//   // Clé publique seulement - SUFFISANT pour un projet académique
//   static const String stripePublishableKey = 'your-publishable-key-here';
//
//   // URL de test Stripe - PAS besoin de votre propre backend
//   static const String stripeTestUrl = 'https://api.stripe.com/v1/payment_intents';
//
//   static Future<void> initialize() async {
//     Stripe.publishableKey = stripePublishableKey;
//     await Stripe.instance.applySettings();
//     print('✅ Stripe initialisé pour projet académique');
//   }
//
//   static Future<void> processPayment({
//     required double amount,
//     required String currency,
//   }) async {
//     try {
//       print('💳 Début du paiement académique: $amount $currency');
//
//       // Créer le PaymentIntent DIRECTEMENT avec Stripe (mode test seulement)
//       final paymentIntent = await _createTestPaymentIntent(
//         amount: amount,
//         currency: currency,
//       );
//
//       // Configurer Stripe
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           merchantDisplayName: 'SmartFit Store - PROJET ACADÉMIQUE',
//           paymentIntentClientSecret: paymentIntent['client_secret'],
//           style: ThemeMode.light,
//           customFlow: false,
//         ),
//       );
//
//       print('📱 Ouverture du formulaire de test...');
//       await Stripe.instance.presentPaymentSheet();
//
//       print('🎉 Paiement de test réussi !');
//
//     } on StripeException catch (e) {
//       print('❌ Erreur Stripe: ${e.error}');
//       throw Exception('Erreur de paiement: ${e.error?.localizedMessage ?? "Annulé"}');
//     } catch (e) {
//       print('❌ Erreur générale: $e');
//       throw Exception('Erreur lors du paiement: $e');
//     }
//   }
//
//   // Méthode spéciale pour projet académique - utilisation de clé test
//   static Future<Map<String, dynamic>> _createTestPaymentIntent({
//     required double amount,
//     required String currency,
//   }) async {
//     try {
//       final amountInCents = (amount * 100).toInt();
//
//       // ⚠️ POUR PROJET ACADÉMIQUE SEULEMENT - ne jamais faire en production
//       final response = await http.post(
//         Uri.parse(stripeTestUrl),
//         headers: {
//           'Authorization': 'Bearer your-test-secret-key-here',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'amount': amountInCents.toString(),
//           'currency': currency.toLowerCase(),
//           'payment_method_types[]': 'card',
//           'description': 'Paiement test - Projet académique',
//         },
//       );
//
//       print('📡 Réponse Stripe Test: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         print('✅ PaymentIntent de test créé');
//         return responseData;
//       } else {
//         final errorData = json.decode(response.body);
//         throw Exception('Erreur Stripe: ${errorData['error']['message']}');
//       }
//     } catch (e) {
//       throw Exception('Erreur de connexion: $e');
//     }
//   }
// }
//
//



import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Clé publique seulement - SUFFISANT pour un projet académique
  static const String stripePublishableKey = 'your-publishable-key-here';

  static const String stripeTestUrl = 'https://api.stripe.com/v1/payment_intents';

  static Future<void> initialize() async {
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();
    print('✅ Stripe initialisé pour projet académique');
  }

  // MÉTHODE PROCESS PAYMENT MANQUANTE - AJOUTÉE ICI
  static Future<void> processPayment({
    required double amount,
    required String currency,
  }) async {
    try {
      print('💳 Début du paiement académique: $amount $currency');

      // Créer le PaymentIntent DIRECTEMENT avec Stripe (mode test seulement)
      final paymentIntent = await _createTestPaymentIntent(
        amount: amount,
        currency: currency,
      );

      // Configurer Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'SmartFit Store - PROJET ACADÉMIQUE',
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.light,
          customFlow: false,
        ),
      );

      print('📱 Ouverture du formulaire de test...');
      await Stripe.instance.presentPaymentSheet();

      print('🎉 Paiement de test réussi !');

    } on StripeException catch (e) {
      print('❌ Erreur Stripe: ${e.error}');
      throw Exception('Erreur de paiement: ${e.error?.localizedMessage ?? "Annulé"}');
    } catch (e) {
      print('❌ Erreur générale: $e');
      throw Exception('Erreur lors du paiement: $e');
    }
  }

  // Méthode spéciale pour projet académique - utilisation de clé test
  static Future<Map<String, dynamic>> _createTestPaymentIntent({
    required double amount,
    required String currency,
  }) async {
    try {
      final amountInCents = (amount * 100).toInt();

      // ⚠️ POUR PROJET ACADÉMIQUE SEULEMENT - ne jamais faire en production
      final response = await http.post(
        Uri.parse(stripeTestUrl),
        headers: {
          'Authorization': 'Bearer your-test-secret-key-here',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency.toLowerCase(),
          'payment_method_types[]': 'card',
          'description': 'Paiement test - Projet académique',
        },
      );

      print('📡 Réponse Stripe Test: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ PaymentIntent de test créé');
        return responseData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Erreur Stripe: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}










