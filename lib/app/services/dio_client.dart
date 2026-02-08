import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../config/app_constants.dart';
import '../routes/app_routes.dart';
import 'storage_service.dart';

/// Central API client with silent token refresh.
/// - Attaches accessToken to every request.
/// - On 401/403: refreshes token, retries request; on refresh failure, logs out and navigates to Sign In.
class DioClient {
  /// Ensure baseUrl ends with / so path concatenation is correct (e.g. baseUrl + 'auth/account-status').
  static String get _baseUrl {
    final url = AppConstants.baseApiUrl;
    return url.endsWith('/') ? url : '$url/';
  }

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('📡 Dio request: ${options.method} ${options.uri}');
          }
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          if (status != 401 && status != 403) {
            return handler.next(error);
          }

          if (kDebugMode) {
            print('🔐 $status received, attempting silent token refresh...');
          }

          try {
            final refreshToken = await StorageService.getRefreshToken();
            if (refreshToken == null || refreshToken.isEmpty) {
              if (kDebugMode) print('🔐 No refresh token, logging out');
              await _logoutAndNavigateToSignIn();
              return handler.next(error);
            }

            // Use a separate Dio instance to avoid interceptor loop
            final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
            final refreshResponse = await refreshDio.post(
              'auth/refresh-token',
              data: {'refreshToken': refreshToken},
              options: Options(
                headers: {'Content-Type': 'application/json'},
              ),
            );

            if (refreshResponse.statusCode == 200) {
              final data = refreshResponse.data;
              final tokenData = data is Map ? data['data'] : null;
              if (tokenData is Map) {
                final accessToken = tokenData['accessToken']?.toString();
                final newRefreshToken = tokenData['refreshToken']?.toString();
                if (accessToken != null && newRefreshToken != null) {
                  await StorageService.saveTokens(
                    accessToken: accessToken,
                    refreshToken: newRefreshToken,
                  );
                  if (kDebugMode) print('🔐 Token refreshed, retrying request');
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $accessToken';
                  final retry = await dio.fetch(error.requestOptions);
                  return handler.resolve(retry);
                }
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('🔐 Token refresh failed: $e');
            }
            await _logoutAndNavigateToSignIn();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<void> _logoutAndNavigateToSignIn() async {
    await StorageService.clearAuthData();
    Get.offAllNamed(AppRoutes.SIGNIN);
  }

  /// GET request
  static Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await instance.get(
      path,
      queryParameters: queryParameters,
    );
    return _toMap(response.data);
  }

  /// POST request
  static Future<Map<String, dynamic>> post(String path,
      {dynamic data}) async {
    final response = await instance.post(path, data: data);
    return _toMap(response.data);
  }

  /// PATCH request
  static Future<Map<String, dynamic>> patch(String path,
      {dynamic data}) async {
    final response = await instance.patch(path, data: data);
    return _toMap(response.data);
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    final response = await instance.put(path, data: data);
    return _toMap(response.data);
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(String path) async {
    final response = await instance.delete(path);
    return _toMap(response.data);
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data == null) return {};
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return {'data': data};
      }
    }
    return {'data': data};
  }
}
