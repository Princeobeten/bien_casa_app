import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Base API Client
/// Handles all HTTP requests with error handling and authentication
class ApiClient {
  final http.Client _client;
  String? _authToken;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Get headers with authentication
  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Get token from storage if not already set
    if (_authToken == null) {
      // Import storage service dynamically to avoid circular dependency
      try {
        final token = await _getStoredToken();
        if (token != null) {
          _authToken = token;
        }
      } catch (e) {
        print('Error getting stored token: $e');
      }
    }

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Get token from storage
  Future<String?> _getStoredToken() async {
    try {
      // Use SharedPreferences directly to avoid circular dependency
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final url = queryParams != null
          ? ApiConfig.buildUrlWithParams(endpoint, queryParams)
          : ApiConfig.buildUrl(endpoint);

      final headers = await _getHeaders();
      final response = await _client
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = ApiConfig.buildUrl(endpoint);
      print('ApiClient: POST $url');
      print('ApiClient: Body: ${body != null ? jsonEncode(body) : "null"}');

      final headers = await _getHeaders();
      print('ApiClient: Headers: $headers');
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      print('ApiClient: Response status: ${response.statusCode}');
      print('ApiClient: Response body: ${response.body}');
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = ApiConfig.buildUrl(endpoint);

      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final url = ApiConfig.buildUrl(endpoint);

      final headers = await _getHeaders();
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = ApiConfig.buildUrl(endpoint);

      final headers = await _getHeaders();
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Upload file (multipart)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
  }) async {
    try {
      final url = ApiConfig.buildUrl(endpoint);
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      final headers = await _getHeaders();
      request.headers.addAll(headers);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(
            ApiConfig.connectionTimeout,
          );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout',
        statusCode: 408,
      );
    } catch (e) {
      throw ApiException(
        message: 'An error occurred: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (statusCode == 401) {
      // Unauthorized
      throw ApiException(
        message: 'Unauthorized. Please login again.',
        statusCode: statusCode,
      );
    } else if (statusCode == 403) {
      // Forbidden
      throw ApiException(
        message: 'Access forbidden',
        statusCode: statusCode,
      );
    } else if (statusCode == 404) {
      // Not found
      throw ApiException(
        message: 'Resource not found',
        statusCode: statusCode,
      );
    } else if (statusCode == 422) {
      // Validation error
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        message: body['message'] ?? 'Validation error',
        statusCode: statusCode,
        errors: body['errors'] as Map<String, dynamic>?,
      );
    } else if (statusCode >= 500) {
      // Server error
      throw ApiException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    } else {
      // Other errors
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        message: body['message'] ?? 'An error occurred',
        statusCode: statusCode,
      );
    }
  }

  /// Close the client
  void close() {
    _client.close();
  }
}
