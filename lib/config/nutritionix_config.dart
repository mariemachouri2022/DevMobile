/// Configuration file for Nutritionix API
///
/// To use the Nutritionix API:
/// 1. Go to https://developer.nutritionix.com/
/// 2. Sign up for a free account
/// 3. Create a new application
/// 4. Copy your App ID and App Key
/// 5. Replace the values below with your credentials
class NutritionixConfig {
  // Replace with your actual Nutritionix API credentials
  static const String appId = '8a95893f';
  static const String appKey = '6d69cd3bb4ae643774ac8b6d77e4a09f';

  // Check if API is configured
  static bool get isConfigured =>
      appId != 'YOUR_APP_ID' && appKey != 'YOUR_APP_KEY';
}
