import 'package:get/get.dart';
import '../../models/lease/house_inspection.dart';
import '../../services/api/inspection_service.dart';
import '../../services/api/api_exception.dart';

/// InspectionController - Manages inspection state
class InspectionController extends GetxController {
  final InspectionService _inspectionService = InspectionService();

  final RxList<HouseInspection> _myInspections = <HouseInspection>[].obs;
  final RxList<HouseInspection> _pendingInspections = <HouseInspection>[].obs;
  final RxList<HouseInspection> _scheduledInspections = <HouseInspection>[].obs;
  final Rx<HouseInspection?> _selectedInspection = Rx<HouseInspection?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<HouseInspection> get myInspections => _myInspections;
  List<HouseInspection> get pendingInspections => _pendingInspections;
  List<HouseInspection> get scheduledInspections => _scheduledInspections;
  HouseInspection? get selectedInspection => _selectedInspection.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch inspections by requester
  Future<void> fetchMyInspections(String requesterId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final inspections = await _inspectionService.getInspectionsByRequester(
        requesterId,
      );
      _myInspections.assignAll(inspections);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch inspections by owner
  Future<void> fetchInspectionsByOwner(String ownerId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final inspections = await _inspectionService.getInspectionsByOwner(
        ownerId,
      );
      _myInspections.assignAll(inspections);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch pending inspections
  Future<void> fetchPendingInspections() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final inspections = await _inspectionService.getPendingInspections();
      _pendingInspections.assignAll(inspections);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch scheduled inspections
  Future<void> fetchScheduledInspections() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final inspections = await _inspectionService.getScheduledInspections();
      _scheduledInspections.assignAll(inspections);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create inspection request
  Future<bool> createInspection(Map<String, dynamic> inspectionData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final inspection = await _inspectionService.createInspection(
        inspectionData,
      );
      _myInspections.insert(0, inspection);
      Get.snackbar(
        'Success',
        'Inspection request created',
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

  /// User agrees to inspection
  Future<bool> userAgree(String id) async {
    try {
      _isLoading.value = true;
      final updated = await _inspectionService.userAgree(id);
      _updateInspectionInLists(updated);
      Get.snackbar(
        'Success',
        'Inspection agreed',
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

  /// Owner agrees to inspection
  Future<bool> ownerAgree(String id) async {
    try {
      _isLoading.value = true;
      final updated = await _inspectionService.ownerAgree(id);
      _updateInspectionInLists(updated);
      Get.snackbar(
        'Success',
        'Inspection agreed',
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

  /// Complete inspection
  Future<bool> completeInspection(String id, String? feedback) async {
    try {
      _isLoading.value = true;
      final updated = await _inspectionService.completeInspection(id, feedback);
      _updateInspectionInLists(updated);
      Get.snackbar(
        'Success',
        'Inspection completed',
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

  /// Cancel inspection
  Future<bool> cancelInspection(String id, String reason) async {
    try {
      _isLoading.value = true;
      final updated = await _inspectionService.cancelInspection(id, reason);
      _updateInspectionInLists(updated);
      Get.snackbar(
        'Success',
        'Inspection cancelled',
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

  /// Reschedule inspection
  Future<bool> rescheduleInspection(
    String id,
    DateTime newDate,
    String newTime,
    String reason,
  ) async {
    try {
      _isLoading.value = true;
      final updated = await _inspectionService.rescheduleInspection(
        id,
        newDate,
        newTime,
        reason,
      );
      _updateInspectionInLists(updated);
      Get.snackbar(
        'Success',
        'Inspection rescheduled',
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

  void _updateInspectionInLists(HouseInspection updated) {
    final myIndex = _myInspections.indexWhere((i) => i.id == updated.id);
    if (myIndex != -1) _myInspections[myIndex] = updated;

    final pendingIndex = _pendingInspections.indexWhere(
      (i) => i.id == updated.id,
    );
    if (pendingIndex != -1) {
      if (updated.isPending) {
        _pendingInspections[pendingIndex] = updated;
      } else {
        _pendingInspections.removeAt(pendingIndex);
      }
    }

    final scheduledIndex = _scheduledInspections.indexWhere(
      (i) => i.id == updated.id,
    );
    if (scheduledIndex != -1) {
      if (updated.isScheduled) {
        _scheduledInspections[scheduledIndex] = updated;
      } else {
        _scheduledInspections.removeAt(scheduledIndex);
      }
    }

    if (_selectedInspection.value?.id == updated.id) {
      _selectedInspection.value = updated;
    }
  }

  void setSelectedInspection(HouseInspection? inspection) {
    _selectedInspection.value = inspection;
  }
}
