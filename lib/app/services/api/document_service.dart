import 'dart:io';
import '../../models/lease/property_document.dart';
import 'api_client.dart';
import 'api_config.dart';

/// DocumentService - Document upload and management
class DocumentService {
  final ApiClient _apiClient;

  DocumentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all documents
  Future<List<PropertyDocument>> getDocuments({
    String? houseLeaseId,
    String? leaseApplicationId,
    String? documentType,
    String? verificationStatus,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (houseLeaseId != null) queryParams['houseLeaseId'] = houseLeaseId;
    if (leaseApplicationId != null) queryParams['leaseApplicationId'] = leaseApplicationId;
    if (documentType != null) queryParams['documentType'] = documentType;
    if (verificationStatus != null) queryParams['verificationStatus'] = verificationStatus;

    final response = await _apiClient.get(
      ApiConfig.documents,
      queryParams: queryParams,
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => PropertyDocument.fromJson(json)).toList();
  }

  /// Get document by ID
  Future<PropertyDocument> getDocumentById(String id) async {
    final response = await _apiClient.get('${ApiConfig.documents}/$id');
    return PropertyDocument.fromJson(response['data']);
  }

  /// Upload document
  Future<PropertyDocument> uploadDocument(
    File file,
    String documentType, {
    String? houseLeaseId,
    String? leaseApplicationId,
  }) async {
    final additionalFields = <String, String>{
      'documentType': documentType,
    };

    if (houseLeaseId != null) additionalFields['houseLeaseId'] = houseLeaseId;
    if (leaseApplicationId != null) additionalFields['leaseApplicationId'] = leaseApplicationId;

    final response = await _apiClient.uploadFile(
      ApiConfig.documents,
      file,
      fieldName: 'document',
      additionalFields: additionalFields,
    );

    return PropertyDocument.fromJson(response['data']);
  }

  /// Delete document
  Future<void> deleteDocument(String id) async {
    await _apiClient.delete('${ApiConfig.documents}/$id');
  }

  /// Verify document (admin only)
  Future<PropertyDocument> verifyDocument(String id) async {
    final response = await _apiClient.patch(
      '${ApiConfig.documents}/$id',
      body: {
        'verificationStatus': 'Verified',
        'verifiedAt': DateTime.now().toIso8601String(),
      },
    );
    return PropertyDocument.fromJson(response['data']);
  }

  /// Reject document (admin only)
  Future<PropertyDocument> rejectDocument(String id, String reason) async {
    final response = await _apiClient.patch(
      '${ApiConfig.documents}/$id',
      body: {
        'verificationStatus': 'Rejected',
        'rejectionReason': reason,
      },
    );
    return PropertyDocument.fromJson(response['data']);
  }

  /// Get documents for lease
  Future<List<PropertyDocument>> getDocumentsForLease(String houseLeaseId) async {
    return await getDocuments(houseLeaseId: houseLeaseId);
  }

  /// Get documents for application
  Future<List<PropertyDocument>> getDocumentsForApplication(String leaseApplicationId) async {
    return await getDocuments(leaseApplicationId: leaseApplicationId);
  }
}
