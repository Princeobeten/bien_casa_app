import '../../models/lease/lease_application.dart';
import 'api_client.dart';
import 'api_config.dart';

/// LeaseApplicationService - Application management
class LeaseApplicationService {
  final ApiClient _apiClient;

  LeaseApplicationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all applications with optional filters
  Future<List<LeaseApplication>> getApplications({
    String? status,
    String? applicantId,
    String? houseLeaseId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (status != null) queryParams['status'] = status;
    if (applicantId != null) queryParams['applicantId'] = applicantId;
    if (houseLeaseId != null) queryParams['houseLeaseId'] = houseLeaseId;

    final response = await _apiClient.get(
      ApiConfig.leaseApplications,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => LeaseApplication.fromJson(json)).toList();
  }

  /// Get application by ID
  Future<LeaseApplication> getApplicationById(String id) async {
    final response = await _apiClient.get('${ApiConfig.leaseApplications}/$id');
    return LeaseApplication.fromJson(response['data']);
  }

  /// Create new application
  Future<LeaseApplication> createApplication(Map<String, dynamic> applicationData) async {
    final response = await _apiClient.post(
      ApiConfig.leaseApplications,
      body: applicationData,
    );
    return LeaseApplication.fromJson(response['data']);
  }

  /// Update application
  Future<LeaseApplication> updateApplication(
    String id,
    Map<String, dynamic> applicationData,
  ) async {
    final response = await _apiClient.put(
      '${ApiConfig.leaseApplications}/$id',
      body: applicationData,
    );
    return LeaseApplication.fromJson(response['data']);
  }

  /// Patch application (partial update)
  Future<LeaseApplication> patchApplication(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.patch(
      '${ApiConfig.leaseApplications}/$id',
      body: updates,
    );
    return LeaseApplication.fromJson(response['data']);
  }

  /// Delete application
  Future<void> deleteApplication(String id) async {
    await _apiClient.delete('${ApiConfig.leaseApplications}/$id');
  }

  /// Approve application (by owner)
  Future<LeaseApplication> approveByOwner(String id) async {
    return await patchApplication(id, {'status': 'Approved_by_owner'});
  }

  /// Approve application (by realtor)
  Future<LeaseApplication> approveByRealtor(String id) async {
    return await patchApplication(id, {'status': 'Approved_by_realtor'});
  }

  /// Decline application (by owner)
  Future<LeaseApplication> declineByOwner(String id, String reason) async {
    return await patchApplication(id, {
      'status': 'Declined_by_owner',
      'declineReason': reason,
    });
  }

  /// Decline application (by realtor)
  Future<LeaseApplication> declineByRealtor(String id, String reason) async {
    return await patchApplication(id, {
      'status': 'Declined_by_realtor',
      'declineReason': reason,
    });
  }

  /// Withdraw application
  Future<LeaseApplication> withdrawApplication(String id) async {
    return await patchApplication(id, {'status': 'Withdrawn'});
  }

  /// Mark as viewed by owner
  Future<LeaseApplication> markAsViewed(String id) async {
    return await patchApplication(id, {
      'viewedByOwner': true,
      'viewedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get applications by applicant
  Future<List<LeaseApplication>> getApplicationsByApplicant(
    String applicantId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getApplications(
      applicantId: applicantId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get applications for a lease
  Future<List<LeaseApplication>> getApplicationsForLease(
    String houseLeaseId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getApplications(
      houseLeaseId: houseLeaseId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get pending applications
  Future<List<LeaseApplication>> getPendingApplications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return await getApplications(
      status: 'Pending_review',
      page: page,
      pageSize: pageSize,
    );
  }

  /// Get approved applications
  Future<List<LeaseApplication>> getApprovedApplications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final ownerApproved = await getApplications(
      status: 'Approved_by_owner',
      page: page,
      pageSize: pageSize,
    );
    final realtorApproved = await getApplications(
      status: 'Approved_by_realtor',
      page: page,
      pageSize: pageSize,
    );
    return [...ownerApproved, ...realtorApproved];
  }
}
