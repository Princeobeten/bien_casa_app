import 'dart:io';
import 'package:get/get.dart';
import '../../models/lease/property_document.dart';
import '../../services/api/document_service.dart';
import '../../services/api/api_exception.dart';

/// DocumentController - Manages document state
class DocumentController extends GetxController {
  final DocumentService _documentService = DocumentService();

  final RxList<PropertyDocument> _documents = <PropertyDocument>[].obs;
  final RxList<PropertyDocument> _leaseDocuments = <PropertyDocument>[].obs;
  final RxList<PropertyDocument> _applicationDocuments =
      <PropertyDocument>[].obs;
  final Rx<PropertyDocument?> _selectedDocument = Rx<PropertyDocument?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUploading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<PropertyDocument> get documents => _documents;
  List<PropertyDocument> get leaseDocuments => _leaseDocuments;
  List<PropertyDocument> get applicationDocuments => _applicationDocuments;
  PropertyDocument? get selectedDocument => _selectedDocument.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch documents for lease
  Future<void> fetchDocumentsForLease(String houseLeaseId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final docs = await _documentService.getDocumentsForLease(houseLeaseId);
      _leaseDocuments.assignAll(docs);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch documents for application
  Future<void> fetchDocumentsForApplication(String leaseApplicationId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final docs = await _documentService.getDocumentsForApplication(
        leaseApplicationId,
      );
      _applicationDocuments.assignAll(docs);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Upload document
  Future<bool> uploadDocument(
    File file,
    String documentType, {
    String? houseLeaseId,
    String? leaseApplicationId,
  }) async {
    try {
      _isUploading.value = true;
      _errorMessage.value = '';

      final document = await _documentService.uploadDocument(
        file,
        documentType,
        houseLeaseId: houseLeaseId,
        leaseApplicationId: leaseApplicationId,
      );

      if (houseLeaseId != null) {
        _leaseDocuments.insert(0, document);
      }
      if (leaseApplicationId != null) {
        _applicationDocuments.insert(0, document);
      }
      _documents.insert(0, document);

      Get.snackbar(
        'Success',
        'Document uploaded successfully',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isUploading.value = false;
    }
  }

  /// Delete document
  Future<bool> deleteDocument(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _documentService.deleteDocument(id);

      _documents.removeWhere((doc) => doc.id == id);
      _leaseDocuments.removeWhere((doc) => doc.id == id);
      _applicationDocuments.removeWhere((doc) => doc.id == id);

      Get.snackbar(
        'Success',
        'Document deleted',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verify document (admin only)
  Future<bool> verifyDocument(String id) async {
    try {
      _isLoading.value = true;
      final updated = await _documentService.verifyDocument(id);
      _updateDocumentInLists(updated);
      Get.snackbar(
        'Success',
        'Document verified',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Reject document (admin only)
  Future<bool> rejectDocument(String id, String reason) async {
    try {
      _isLoading.value = true;
      final updated = await _documentService.rejectDocument(id, reason);
      _updateDocumentInLists(updated);
      Get.snackbar(
        'Success',
        'Document rejected',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void _updateDocumentInLists(PropertyDocument updated) {
    final index = _documents.indexWhere((d) => d.id == updated.id);
    if (index != -1) _documents[index] = updated;

    final leaseIndex = _leaseDocuments.indexWhere((d) => d.id == updated.id);
    if (leaseIndex != -1) _leaseDocuments[leaseIndex] = updated;

    final appIndex = _applicationDocuments.indexWhere(
      (d) => d.id == updated.id,
    );
    if (appIndex != -1) _applicationDocuments[appIndex] = updated;

    if (_selectedDocument.value?.id == updated.id) {
      _selectedDocument.value = updated;
    }
  }

  void setSelectedDocument(PropertyDocument? document) {
    _selectedDocument.value = document;
  }
}
