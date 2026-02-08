import 'package:get/get.dart';
import '../../models/lease/house_hold_history.dart';
import '../../services/api/hold_service.dart';
import '../../services/api/api_exception.dart';

/// HoldController - Manages property holds
class HoldController extends GetxController {
  final HoldService _holdService = HoldService();

  final RxList<HouseHoldHistory> _holds = <HouseHoldHistory>[].obs;
  final RxList<HouseHoldHistory> _activeHolds = <HouseHoldHistory>[].obs;
  final Rx<HouseHoldHistory?> _selectedHold = Rx<HouseHoldHistory?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<HouseHoldHistory> get holds => _holds;
  List<HouseHoldHistory> get activeHolds => _activeHolds;
  HouseHoldHistory? get selectedHold => _selectedHold.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch holds by user
  Future<void> fetchHolds(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final holds = await _holdService.getHolds(userId: userId);
      _holds.assignAll(holds);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch active holds
  Future<void> fetchActiveHolds(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final holds = await _holdService.getActiveHolds(userId);
      _activeHolds.assignAll(holds);
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Fetch hold by ID
  Future<void> fetchHoldById(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final hold = await _holdService.getHoldById(id);
      _selectedHold.value = hold;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Create hold
  Future<bool> createHold(Map<String, dynamic> holdData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final hold = await _holdService.createHold(holdData);
      _holds.insert(0, hold);
      _activeHolds.insert(0, hold);

      Get.snackbar(
        'Success',
        'Property hold created',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Cancel hold
  Future<bool> cancelHold(String id, String reason) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedHold = await _holdService.cancelHold(id, reason);
      _updateHoldInLists(updatedHold);

      Get.snackbar(
        'Success',
        'Hold cancelled',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Complete hold
  Future<bool> completeHold(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedHold = await _holdService.completeHold(id);
      _updateHoldInLists(updatedHold);

      Get.snackbar(
        'Success',
        'Hold completed',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Check if property is on hold
  Future<bool> isPropertyOnHold(String houseLeaseId) async {
    try {
      return await _holdService.isPropertyOnHold(houseLeaseId);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.TOP);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
  }

  /// Update hold in lists
  void _updateHoldInLists(HouseHoldHistory updatedHold) {
    final index = _holds.indexWhere((h) => h.id == updatedHold.id);
    if (index != -1) _holds[index] = updatedHold;

    final activeIndex = _activeHolds.indexWhere((h) => h.id == updatedHold.id);
    if (activeIndex != -1) {
      if (updatedHold.isActive) {
        _activeHolds[activeIndex] = updatedHold;
      } else {
        _activeHolds.removeAt(activeIndex);
      }
    }

    if (_selectedHold.value?.id == updatedHold.id) {
      _selectedHold.value = updatedHold;
    }
  }

  /// Set selected hold
  void setSelectedHold(HouseHoldHistory? hold) {
    _selectedHold.value = hold;
  }

  /// Clear selected hold
  void clearSelectedHold() {
    _selectedHold.value = null;
  }

  /// Get hold for property
  HouseHoldHistory? getHoldForProperty(String houseLeaseId) {
    try {
      return _activeHolds.firstWhere((h) => h.houseLeaseId == houseLeaseId);
    } catch (e) {
      return null;
    }
  }
}
