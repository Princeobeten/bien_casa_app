import '../../models/lease/house_hold_history.dart';
import 'api_client.dart';
import 'api_config.dart';

/// HoldService - Property hold operations
class HoldService {
  final ApiClient _apiClient;

  HoldService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get holds
  Future<List<HouseHoldHistory>> getHolds({
    String? userId,
    String? houseLeaseId,
    String? holdStatus,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (userId != null) queryParams['userId'] = userId;
    if (houseLeaseId != null) queryParams['houseLeaseId'] = houseLeaseId;
    if (holdStatus != null) queryParams['holdStatus'] = holdStatus;

    final response = await _apiClient.get(
      ApiConfig.holds,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => HouseHoldHistory.fromJson(json)).toList();
  }

  /// Get hold by ID
  Future<HouseHoldHistory> getHoldById(String id) async {
    final response = await _apiClient.get('${ApiConfig.holds}/$id');
    return HouseHoldHistory.fromJson(response['data']);
  }

  /// Create hold
  Future<HouseHoldHistory> createHold(Map<String, dynamic> holdData) async {
    final response = await _apiClient.post(
      ApiConfig.holds,
      body: holdData,
    );
    return HouseHoldHistory.fromJson(response['data']);
  }

  /// Update hold status
  Future<HouseHoldHistory> updateHoldStatus(String id, String status) async {
    final response = await _apiClient.patch(
      '${ApiConfig.holds}/$id',
      body: {'holdStatus': status},
    );
    return HouseHoldHistory.fromJson(response['data']);
  }

  /// Cancel hold
  Future<HouseHoldHistory> cancelHold(String id, String reason) async {
    final response = await _apiClient.patch(
      '${ApiConfig.holds}/$id',
      body: {
        'holdStatus': 'Cancelled',
        'cancelledAt': DateTime.now().toIso8601String(),
        'cancellationReason': reason,
      },
    );
    return HouseHoldHistory.fromJson(response['data']);
  }

  /// Complete hold
  Future<HouseHoldHistory> completeHold(String id) async {
    final response = await _apiClient.patch(
      '${ApiConfig.holds}/$id',
      body: {
        'holdStatus': 'Completed',
        'completedAt': DateTime.now().toIso8601String(),
      },
    );
    return HouseHoldHistory.fromJson(response['data']);
  }

  /// Get active holds for user
  Future<List<HouseHoldHistory>> getActiveHolds(String userId) async {
    return await getHolds(userId: userId, holdStatus: 'Active');
  }

  /// Check if property is on hold
  Future<bool> isPropertyOnHold(String houseLeaseId) async {
    final holds = await getHolds(houseLeaseId: houseLeaseId, holdStatus: 'Active');
    return holds.isNotEmpty;
  }
}
