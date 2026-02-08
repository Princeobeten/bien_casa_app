import '../../models/lease/house_inspection.dart';
import 'api_client.dart';
import 'api_config.dart';

/// InspectionService - Inspection scheduling and management
class InspectionService {
  final ApiClient _apiClient;

  InspectionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all inspections with optional filters
  Future<List<HouseInspection>> getInspections({
    String? status,
    String? requesterId,
    String? ownerId,
    String? houseLeaseId,
    String? campaignId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (status != null) queryParams['status'] = status;
    if (requesterId != null) queryParams['requesterId'] = requesterId;
    if (ownerId != null) queryParams['ownerId'] = ownerId;
    if (houseLeaseId != null) queryParams['houseLeaseId'] = houseLeaseId;
    if (campaignId != null) queryParams['campaignId'] = campaignId;

    final response = await _apiClient.get(
      ApiConfig.inspections,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => HouseInspection.fromJson(json)).toList();
  }

  /// Get inspection by ID
  Future<HouseInspection> getInspectionById(String id) async {
    final response = await _apiClient.get('${ApiConfig.inspections}/$id');
    return HouseInspection.fromJson(response['data']);
  }

  /// Create new inspection request
  Future<HouseInspection> createInspection(Map<String, dynamic> inspectionData) async {
    final response = await _apiClient.post(
      ApiConfig.inspections,
      body: inspectionData,
    );
    return HouseInspection.fromJson(response['data']);
  }

  /// Update inspection
  Future<HouseInspection> updateInspection(
    String id,
    Map<String, dynamic> inspectionData,
  ) async {
    final response = await _apiClient.put(
      '${ApiConfig.inspections}/$id',
      body: inspectionData,
    );
    return HouseInspection.fromJson(response['data']);
  }

  /// Patch inspection (partial update)
  Future<HouseInspection> patchInspection(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.patch(
      '${ApiConfig.inspections}/$id',
      body: updates,
    );
    return HouseInspection.fromJson(response['data']);
  }

  /// Delete inspection
  Future<void> deleteInspection(String id) async {
    await _apiClient.delete('${ApiConfig.inspections}/$id');
  }

  /// User agrees to inspection
  Future<HouseInspection> userAgree(String id) async {
    return await patchInspection(id, {'userAgreed': true});
  }

  /// Owner agrees to inspection
  Future<HouseInspection> ownerAgree(String id) async {
    return await patchInspection(id, {'ownerAgreed': true});
  }

  /// Schedule inspection (both parties agreed)
  Future<HouseInspection> scheduleInspection(String id) async {
    return await patchInspection(id, {'status': 'Scheduled'});
  }

  /// Complete inspection
  Future<HouseInspection> completeInspection(String id, String? feedback) async {
    return await patchInspection(id, {
      'status': 'Completed',
      'completedAt': DateTime.now().toIso8601String(),
      if (feedback != null) 'feedback': feedback,
    });
  }

  /// Cancel inspection
  Future<HouseInspection> cancelInspection(String id, String reason) async {
    return await patchInspection(id, {
      'status': 'Cancelled',
      'cancelledAt': DateTime.now().toIso8601String(),
      'cancellationReason': reason,
    });
  }

  /// Reschedule inspection
  Future<HouseInspection> rescheduleInspection(
    String id,
    DateTime newDate,
    String newTime,
    String reason,
  ) async {
    return await patchInspection(id, {
      'status': 'Rescheduled',
      'inspectionDate': newDate.toIso8601String(),
      'inspectionTime': newTime,
      'rescheduledReason': reason,
    });
  }

  /// Get inspections by requester
  Future<List<HouseInspection>> getInspectionsByRequester(
    String requesterId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getInspections(
      requesterId: requesterId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get inspections by owner
  Future<List<HouseInspection>> getInspectionsByOwner(
    String ownerId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getInspections(
      ownerId: ownerId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get pending inspections
  Future<List<HouseInspection>> getPendingInspections({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getInspections(
      status: 'Pending',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get scheduled inspections
  Future<List<HouseInspection>> getScheduledInspections({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getInspections(
      status: 'Scheduled',
      page: page,
      pageSize: pageSize,
    );
  }
}
