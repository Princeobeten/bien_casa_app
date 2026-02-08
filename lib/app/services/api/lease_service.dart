import '../../models/lease/house_lease.dart';
import 'api_client.dart';
import 'api_config.dart';

/// LeaseService - CRUD operations for house leases
class LeaseService {
  final ApiClient _apiClient;

  LeaseService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all leases with optional filters
  Future<List<HouseLease>> getLeases({
    String? status,
    String? propertyStatus,
    String? category,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? city,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (status != null) queryParams['status'] = status;
    if (propertyStatus != null) queryParams['propertyStatus'] = propertyStatus;
    if (category != null) queryParams['category'] = category;
    if (propertyType != null) queryParams['propertyType'] = propertyType;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (city != null) queryParams['city'] = city;

    final response = await _apiClient.get(
      ApiConfig.leases,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => HouseLease.fromJson(json)).toList();
  }

  /// Get lease by ID
  Future<HouseLease> getLeaseById(String id) async {
    final response = await _apiClient.get('${ApiConfig.leases}/$id');
    return HouseLease.fromJson(response['data']);
  }

  /// Create new lease
  Future<HouseLease> createLease(Map<String, dynamic> leaseData) async {
    final response = await _apiClient.post(
      ApiConfig.leases,
      body: leaseData,
    );
    return HouseLease.fromJson(response['data']);
  }

  /// Update lease
  Future<HouseLease> updateLease(String id, Map<String, dynamic> leaseData) async {
    final response = await _apiClient.put(
      '${ApiConfig.leases}/$id',
      body: leaseData,
    );
    return HouseLease.fromJson(response['data']);
  }

  /// Patch lease (partial update)
  Future<HouseLease> patchLease(String id, Map<String, dynamic> updates) async {
    final response = await _apiClient.patch(
      '${ApiConfig.leases}/$id',
      body: updates,
    );
    return HouseLease.fromJson(response['data']);
  }

  /// Delete lease
  Future<void> deleteLease(String id) async {
    await _apiClient.delete('${ApiConfig.leases}/$id');
  }

  /// Publish lease (change status from Draft to Active)
  Future<HouseLease> publishLease(String id) async {
    return await patchLease(id, {'status': 'Active'});
  }

  /// Close lease
  Future<HouseLease> closeLease(String id) async {
    return await patchLease(id, {'status': 'Closed'});
  }

  /// Update property status
  Future<HouseLease> updatePropertyStatus(String id, String status) async {
    return await patchLease(id, {'propertyStatus': status});
  }

  /// Mark property as occupied
  Future<HouseLease> markAsOccupied(String id) async {
    return await updatePropertyStatus(id, 'Occupied');
  }

  /// Mark property as available
  Future<HouseLease> markAsAvailable(String id) async {
    return await updatePropertyStatus(id, 'Available');
  }

  /// Get leases by owner
  Future<List<HouseLease>> getLeasesByOwner(String ownerId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = {
      'ownerId': ownerId,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get(
      ApiConfig.leases,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => HouseLease.fromJson(json)).toList();
  }

  /// Search leases
  Future<List<HouseLease>> searchLeases(String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = {
      'search': query,
      'page': page,
      'pageSize': pageSize,
    };

    final response = await _apiClient.get(
      '${ApiConfig.leases}/search',
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => HouseLease.fromJson(json)).toList();
  }

  /// Get available leases
  Future<List<HouseLease>> getAvailableLeases({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getLeases(
      status: 'Active',
      propertyStatus: 'Available',
      page: page,
      pageSize: pageSize,
    );
  }
}
