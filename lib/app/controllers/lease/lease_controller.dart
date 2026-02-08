import 'package:get/get.dart';
import '../../models/lease/house_lease.dart';
import '../../services/api/lease_service.dart';
import '../../services/api/api_exception.dart';

/// LeaseController - Manages house lease state and operations
class LeaseController extends GetxController {
  final LeaseService _leaseService = LeaseService();

  // Observable lists
  final RxList<HouseLease> _allLeases = <HouseLease>[].obs;
  final RxList<HouseLease> _availableLeases = <HouseLease>[].obs;
  final RxList<HouseLease> _myLeases = <HouseLease>[].obs;
  final Rx<HouseLease?> _selectedLease = Rx<HouseLease?>(null);

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;

  // Pagination
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;

  // Filters
  final RxString _selectedStatus = ''.obs;
  final RxString _selectedCategory = ''.obs;
  final RxString _selectedPropertyType = ''.obs;
  final RxString _selectedCity = ''.obs;
  final RxDouble _minPrice = 0.0.obs;
  final RxDouble _maxPrice = 0.0.obs;

  // Getters
  List<HouseLease> get allLeases => _allLeases;
  List<HouseLease> get availableLeases => _availableLeases;
  List<HouseLease> get myLeases => _myLeases;
  HouseLease? get selectedLease => _selectedLease.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;
  bool get hasMoreData => _hasMoreData.value;

  @override
  void onInit() {
    super.onInit();
    fetchAvailableLeases();
  }

  /// Fetch all leases with filters
  Future<void> fetchLeases({bool loadMore = false}) async {
    try {
      if (loadMore) {
        _isLoadingMore.value = true;
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _allLeases.clear();
      }

      _errorMessage.value = '';

      final leases = await _leaseService.getLeases(
        status: _selectedStatus.value.isEmpty ? null : _selectedStatus.value,
        category:
            _selectedCategory.value.isEmpty ? null : _selectedCategory.value,
        propertyType:
            _selectedPropertyType.value.isEmpty
                ? null
                : _selectedPropertyType.value,
        city: _selectedCity.value.isEmpty ? null : _selectedCity.value,
        minPrice: _minPrice.value > 0 ? _minPrice.value : null,
        maxPrice: _maxPrice.value > 0 ? _maxPrice.value : null,
        page: _currentPage.value,
      );

      if (leases.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _allLeases.addAll(leases);
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
      _isLoadingMore.value = false;
    }
  }

  /// Fetch available leases
  Future<void> fetchAvailableLeases({bool loadMore = false}) async {
    try {
      if (loadMore) {
        _isLoadingMore.value = true;
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _availableLeases.clear();
      }

      _errorMessage.value = '';

      final leases = await _leaseService.getAvailableLeases(
        page: _currentPage.value,
      );

      if (leases.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _availableLeases.addAll(leases);
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
      _isLoadingMore.value = false;
    }
  }

  /// Fetch leases by owner
  Future<void> fetchMyLeases(String ownerId, {bool loadMore = false}) async {
    try {
      if (loadMore) {
        _isLoadingMore.value = true;
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _myLeases.clear();
      }

      _errorMessage.value = '';

      final leases = await _leaseService.getLeasesByOwner(
        ownerId,
        page: _currentPage.value,
      );

      if (leases.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _myLeases.addAll(leases);
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
      _isLoadingMore.value = false;
    }
  }

  /// Fetch lease by ID
  Future<void> fetchLeaseById(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final lease = await _leaseService.getLeaseById(id);
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

  /// Create new lease
  Future<bool> createLease(Map<String, dynamic> leaseData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final lease = await _leaseService.createLease(leaseData);
      _myLeases.insert(0, lease);

      Get.snackbar(
        'Success',
        'Lease created successfully',
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

  /// Update lease
  Future<bool> updateLease(String id, Map<String, dynamic> leaseData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedLease = await _leaseService.updateLease(id, leaseData);

      // Update in lists
      _updateLeaseInLists(updatedLease);

      if (_selectedLease.value?.id == id) {
        _selectedLease.value = updatedLease;
      }

      Get.snackbar(
        'Success',
        'Lease updated successfully',
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

  /// Publish lease
  Future<bool> publishLease(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedLease = await _leaseService.publishLease(id);
      _updateLeaseInLists(updatedLease);

      Get.snackbar(
        'Success',
        'Lease published successfully',
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

  /// Close lease
  Future<bool> closeLease(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedLease = await _leaseService.closeLease(id);
      _updateLeaseInLists(updatedLease);

      Get.snackbar(
        'Success',
        'Lease closed successfully',
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

  /// Mark as occupied
  Future<bool> markAsOccupied(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedLease = await _leaseService.markAsOccupied(id);
      _updateLeaseInLists(updatedLease);

      Get.snackbar(
        'Success',
        'Property marked as occupied',
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

  /// Mark as available
  Future<bool> markAsAvailable(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedLease = await _leaseService.markAsAvailable(id);
      _updateLeaseInLists(updatedLease);

      Get.snackbar(
        'Success',
        'Property marked as available',
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

  /// Delete lease
  Future<bool> deleteLease(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _leaseService.deleteLease(id);

      // Remove from lists
      _allLeases.removeWhere((lease) => lease.id == id);
      _availableLeases.removeWhere((lease) => lease.id == id);
      _myLeases.removeWhere((lease) => lease.id == id);

      Get.snackbar(
        'Success',
        'Lease deleted successfully',
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

  /// Search leases
  Future<void> searchLeases(String query) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _allLeases.clear();

      final leases = await _leaseService.searchLeases(query);
      _allLeases.addAll(leases);
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

  /// Apply filters
  void applyFilters({
    String? status,
    String? category,
    String? propertyType,
    String? city,
    double? minPrice,
    double? maxPrice,
  }) {
    if (status != null) _selectedStatus.value = status;
    if (category != null) _selectedCategory.value = category;
    if (propertyType != null) _selectedPropertyType.value = propertyType;
    if (city != null) _selectedCity.value = city;
    if (minPrice != null) _minPrice.value = minPrice;
    if (maxPrice != null) _maxPrice.value = maxPrice;

    fetchLeases();
  }

  /// Clear filters
  void clearFilters() {
    _selectedStatus.value = '';
    _selectedCategory.value = '';
    _selectedPropertyType.value = '';
    _selectedCity.value = '';
    _minPrice.value = 0.0;
    _maxPrice.value = 0.0;
    fetchLeases();
  }

  /// Refresh data
  Future<void> refresh() async {
    _currentPage.value = 1;
    _hasMoreData.value = true;
    await fetchAvailableLeases();
  }

  /// Helper to update lease in all lists
  void _updateLeaseInLists(HouseLease updatedLease) {
    final index = _allLeases.indexWhere((l) => l.id == updatedLease.id);
    if (index != -1) _allLeases[index] = updatedLease;

    final availIndex = _availableLeases.indexWhere(
      (l) => l.id == updatedLease.id,
    );
    if (availIndex != -1) _availableLeases[availIndex] = updatedLease;

    final myIndex = _myLeases.indexWhere((l) => l.id == updatedLease.id);
    if (myIndex != -1) _myLeases[myIndex] = updatedLease;
  }

  /// Set selected lease
  void setSelectedLease(HouseLease? lease) {
    _selectedLease.value = lease;
  }

  /// Clear selected lease
  void clearSelectedLease() {
    _selectedLease.value = null;
  }
}
