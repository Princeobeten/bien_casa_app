import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration
  static String get baseApiUrl => dotenv.get('BASE_API_URL', fallback: '');
  static String get apiDoc => dotenv.get('API_DOC_URL', fallback: '');

  // Google Maps API Key
  static String get googleMapsApiKey => dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');

  // LocationIQ API Key
  static String get locationIqApiKey => dotenv.get('LOCATIONIQ_API_KEY', fallback: '');

  // Environment Settings
  static String get environment => dotenv.get('ENVIRONMENT', fallback: 'development');
  static bool get debugMode => dotenv.get('DEBUG_MODE', fallback: 'true') == 'true';
}
