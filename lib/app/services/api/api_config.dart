import '../../config/app_constants.dart';

/// API Configuration
/// Central configuration for all API endpoints and settings
class ApiConfig {
  // Base URLs - Using AppConstants for consistency
  static final String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: AppConstants.baseApiUrl,
  );

  static const String stagingUrl = 'https://bien-casa-be-mvp.up.railway.app/api';
  static  String productionUrl = AppConstants.baseApiUrl;

  // Environment
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Endpoints - Lease Management
  static const String leases = '/leases';
  static const String leaseApplications = '/lease-applications';
  static const String activeLeases = '/active-leases';
  static const String inspections = '/inspections';
  static const String documents = '/documents';
  static const String favourites = '/favourites';
  static const String holds = '/holds';

  // API Endpoints - Campaign Management
  static const String campaigns = '/campaigns';
  static const String flatmateRequests = '/flatmate-requests';
  static const String campaignHouses = '/campaign-houses';
  static const String campaignContributions = '/campaign-contributions';
  static const String transferRequests = '/transfer-requests';

  // API Endpoints - Payment
  static const String payments = '/payments';
  static const String escrow = '/escrow';
  static const String wallet = '/wallet';

  // API Endpoints - User Management
  static const String users = '/users';
  static const String auth = '/auth';
  static const String profile = '/profile';

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  ];
  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'image/jpeg',
    'image/jpg',
    'image/png',
  ];

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheExpiry = Duration(minutes: 5);

  // Get current base URL based on environment
  static String get currentBaseUrl {
    if (isProduction) return productionUrl;
    return stagingUrl;
  }

  // Build full URL
  static String buildUrl(String endpoint) {
    return '$currentBaseUrl$endpoint';
  }

  // Build URL with query parameters
  static String buildUrlWithParams(String endpoint, Map<String, dynamic> params) {
    final uri = Uri.parse('$currentBaseUrl$endpoint');
    final newUri = uri.replace(queryParameters: params.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
    return newUri.toString();
  }
}
