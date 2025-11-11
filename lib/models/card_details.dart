// Modèle SIMPLIFIÉ - Plus facile à utiliser
class CardDetails {
  String cardNumber = '';
  String expiryDate = '';
  String cvc = '';
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String city = '';
  String postalCode = '';
  String country = 'FR';

  CardDetails();

  // Valider que tous les champs requis sont remplis
  bool get isValid {
    return cardNumber.replaceAll(' ', '').length >= 16 &&
        expiryDate.length >= 5 &&
        cvc.length >= 3 &&
        name.isNotEmpty &&
        email.isNotEmpty;
  }
}