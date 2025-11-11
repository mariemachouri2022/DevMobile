/// Configuration file for Edamam Nutrition API
///
/// To use the Edamam API:
/// 1. Go to https://developer.edamam.com/edamam-nutrition-api
/// 2. Sign up for an account
/// 3. Create a new application
/// 4. Copy your Application ID and Application Key
/// 5. Replace the values below with your credentials
class NutritionixConfig {
  // Edamam API credentials
  static const String appId = 'd4fabbc9';
  static const String appKey = 'dccc0f7092039dc6c9ac5b3b018d4406';

  // Check if API is configured
  static bool get isConfigured =>
      appId != 'YOUR_APP_ID' && appKey != 'YOUR_APP_KEY';
}
