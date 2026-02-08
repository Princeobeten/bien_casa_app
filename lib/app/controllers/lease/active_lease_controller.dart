import 'package:get/get.dart';
import '../../models/lease/active_lease.dart';
import '../../services/api/api_client.dart';
import '../../services/api/api_config.dart';
import '../../services/api/api_exception.dart';

/// ActiveLeaseController - Manages active lease state
class ActiveLeaseController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final RxList<ActiveLease> _activeLeases = <ActiveLease>[].obs;
  final RxList<ActiveLease> _myActiveLeases = <ActiveLease>[].obs;
  final Rx<ActiveLease?> _selectedLease = Rx<ActiveLease?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<ActiveLease> get activeLeases => _activeLeases;
  List<ActiveLease> get myActiveLeases => _myActiveLeases;
  ActiveLease? get selectedLease => _selectedLease.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch all active leases
  Future<void> fetchActiveLeases({String? status, int page = 1}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final queryParams = <String, dynamic>{'page': page, 'pageSize': 20};
      if (status != null) queryParams['leaseStatus'] = status;

      final response = await _apiClient.get(
        ApiConfig.activeLeases,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] as List<dynamic>;
      final leases = data.map((json) => ActiveLease.fromJson(json)).toList();

      if (page == 1) {
        _activeLeases.assignAll(leases);
      } else {
        _activeLeases.addAll(leases);
      }
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

  /// Fetch active leases by tenant
  Future<void> fetchMyActiveLeases(String tenantId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiClient.get(
        ApiConfig.activeLeases,
        queryParams: {'tenantId': tenantId},
      );

      final List<dynamic> data = response['data'] as List<dynamic>;
      final leases = data.map((json) => ActiveLease.fromJson(json)).toList();
      _myActiveLeases.assignAll(leases);
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

  /// Fetch active leases by owner
  Future<void> fetchActiveLeasesByOwner(String ownerId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiClient.get(
        ApiConfig.activeLeases,
        queryParams: {'ownerId': ownerId},
      );

      final List<dynamic> data = response['data'] as List<dynamic>;
      final leases = data.map((json) => ActiveLease.fromJson(json)).toList();
      _myActiveLeases.assignAll(leases);
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

  /// Fetch active lease by ID
  Future<void> fetchActiveLeaseById(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiClient.get('${ApiConfig.activeLeases}/$id');
      final lease = ActiveLease.fromJson(response['data']);
      _selectedLease.value = lease;
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

  /// Create active lease
  Future<bool> createActiveLease(Map<String, dynamic> leaseData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiClient.post(
        ApiConfig.activeLeases,
        body: leaseData,
      );

      final lease = ActiveLease.fromJson(response['data']);
      _myActiveLeases.insert(0, lease);

      Get.snackbar(
        'Success',
        'Active lease created',
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

  /// Update active lease
  Future<bool> updateActiveLease(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _apiClient.patch(
        '${ApiConfig.activeLeases}/$id',
        body: updates,
      );

      final updatedLease = ActiveLease.fromJson(response['data']);
      _updateLeaseInLists(updatedLease);

      Get.snackbar(
        'Success',
        'Lease updated',
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

  /// Tenant accepts lease
  Future<bool> tenantAcceptLease(String id) async {
    return await updateActiveLease(id, {'tenantAccepted': true});
  }

  /// Owner accepts lease
  Future<bool> ownerAcceptLease(String id) async {
    return await updateActiveLease(id, {'ownerAccepted': true});
  }

  /// Terminate lease
  Future<bool> terminateLease(String id, String reason) async {
    return await updateActiveLease(id, {
      'leaseStatus': 'Terminated',
      'terminatedAt': DateTime.now().toIso8601String(),
      'terminationReason': reason,
    });
  }

  /// Renew lease
  Future<bool> renewLease(String id) async {
    return await updateActiveLease(id, {'leaseStatus': 'Renewed'});
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String id, String status) async {
    return await updateActiveLease(id, {'paymentStatus': status});
  }

  /// Update lease in lists
  void _updateLeaseInLists(ActiveLease updatedLease) {
    final index = _activeLeases.indexWhere((l) => l.id == updatedLease.id);
    if (index != -1) _activeLeases[index] = updatedLease;

    final myIndex = _myActiveLeases.indexWhere((l) => l.id == updatedLease.id);
    if (myIndex != -1) _myActiveLeases[myIndex] = updatedLease;

    if (_selectedLease.value?.id == updatedLease.id) {
      _selectedLease.value = updatedLease;
    }
  }

  /// Set selected lease
  void setSelectedLease(ActiveLease? lease) {
    _selectedLease.value = lease;
  }

  /// Clear selected lease
  void clearSelectedLease() {
    _selectedLease.value = null;
  }

  /// Get active lease for property
  ActiveLease? getActiveLeaseForProperty(String houseLeaseId) {
    try {
      return _myActiveLeases.firstWhere((l) => l.houseLeaseId == houseLeaseId);
    } catch (e) {
      return null;
    }
  }

  /// Get leases ending soon
  List<ActiveLease> get leasesEndingSoon {
    return _myActiveLeases.where((lease) => lease.isEndingSoon).toList();
  }

  /// Get active leases only
  List<ActiveLease> get onlyActiveLeases {
    return _myActiveLeases.where((lease) => lease.isActive).toList();
  }
}
