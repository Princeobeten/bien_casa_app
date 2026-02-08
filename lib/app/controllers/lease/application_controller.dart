import 'package:get/get.dart';
import '../../models/lease/lease_application.dart';
import '../../services/api/lease_application_service.dart';
import '../../services/api/api_exception.dart';

/// ApplicationController - Manages lease application state
class ApplicationController extends GetxController {
  final LeaseApplicationService _applicationService = LeaseApplicationService();

  // Observable lists
  final RxList<LeaseApplication> _myApplications = <LeaseApplication>[].obs;
  final RxList<LeaseApplication> _receivedApplications =
      <LeaseApplication>[].obs;
  final RxList<LeaseApplication> _pendingApplications =
      <LeaseApplication>[].obs;
  final Rx<LeaseApplication?> _selectedApplication = Rx<LeaseApplication?>(
    null,
  );

  // Loading states
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Pagination
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;

  // Getters
  List<LeaseApplication> get myApplications => _myApplications;
  List<LeaseApplication> get receivedApplications => _receivedApplications;
  List<LeaseApplication> get pendingApplications => _pendingApplications;
  LeaseApplication? get selectedApplication => _selectedApplication.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch applications by applicant
  Future<void> fetchMyApplications(
    String applicantId, {
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _myApplications.clear();
      }

      _errorMessage.value = '';

      final applications = await _applicationService.getApplicationsByApplicant(
        applicantId,
        page: _currentPage.value,
      );

      if (applications.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _myApplications.addAll(applications);
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

  /// Fetch applications for a lease (for owners)
  Future<void> fetchApplicationsForLease(
    String houseLeaseId, {
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _receivedApplications.clear();
      }

      _errorMessage.value = '';

      final applications = await _applicationService.getApplicationsForLease(
        houseLeaseId,
        page: _currentPage.value,
      );

      if (applications.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _receivedApplications.addAll(applications);
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

  /// Fetch pending applications
  Future<void> fetchPendingApplications({bool loadMore = false}) async {
    try {
      if (loadMore) {
        _currentPage.value++;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _pendingApplications.clear();
      }

      _errorMessage.value = '';

      final applications = await _applicationService.getPendingApplications(
        page: _currentPage.value,
      );

      if (applications.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _pendingApplications.addAll(applications);
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

  /// Fetch application by ID
  Future<void> fetchApplicationById(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final application = await _applicationService.getApplicationById(id);
      _selectedApplication.value = application;
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

  /// Create new application
  Future<bool> createApplication(Map<String, dynamic> applicationData) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final application = await _applicationService.createApplication(
        applicationData,
      );
      _myApplications.insert(0, application);

      Get.snackbar(
        'Success',
        'Application submitted successfully',
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

  /// Approve application (by owner)
  Future<bool> approveByOwner(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedApplication = await _applicationService.approveByOwner(id);
      _updateApplicationInLists(updatedApplication);

      Get.snackbar(
        'Success',
        'Application approved',
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

  /// Approve application (by realtor)
  Future<bool> approveByRealtor(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedApplication = await _applicationService.approveByRealtor(id);
      _updateApplicationInLists(updatedApplication);

      Get.snackbar(
        'Success',
        'Application approved',
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

  /// Decline application (by owner)
  Future<bool> declineByOwner(String id, String reason) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedApplication = await _applicationService.declineByOwner(
        id,
        reason,
      );
      _updateApplicationInLists(updatedApplication);

      Get.snackbar(
        'Success',
        'Application declined',
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

  /// Decline application (by realtor)
  Future<bool> declineByRealtor(String id, String reason) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedApplication = await _applicationService.declineByRealtor(
        id,
        reason,
      );
      _updateApplicationInLists(updatedApplication);

      Get.snackbar(
        'Success',
        'Application declined',
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

  /// Withdraw application
  Future<bool> withdrawApplication(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final updatedApplication = await _applicationService.withdrawApplication(
        id,
      );
      _updateApplicationInLists(updatedApplication);

      Get.snackbar(
        'Success',
        'Application withdrawn',
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

  /// Mark as viewed by owner
  Future<bool> markAsViewed(String id) async {
    try {
      final updatedApplication = await _applicationService.markAsViewed(id);
      _updateApplicationInLists(updatedApplication);
      return true;
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      return false;
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred';
      return false;
    }
  }

  /// Helper to update application in all lists
  void _updateApplicationInLists(LeaseApplication updatedApplication) {
    final myIndex = _myApplications.indexWhere(
      (a) => a.id == updatedApplication.id,
    );
    if (myIndex != -1) _myApplications[myIndex] = updatedApplication;

    final receivedIndex = _receivedApplications.indexWhere(
      (a) => a.id == updatedApplication.id,
    );
    if (receivedIndex != -1)
      _receivedApplications[receivedIndex] = updatedApplication;

    final pendingIndex = _pendingApplications.indexWhere(
      (a) => a.id == updatedApplication.id,
    );
    if (pendingIndex != -1) {
      if (updatedApplication.isPending) {
        _pendingApplications[pendingIndex] = updatedApplication;
      } else {
        _pendingApplications.removeAt(pendingIndex);
      }
    }

    if (_selectedApplication.value?.id == updatedApplication.id) {
      _selectedApplication.value = updatedApplication;
    }
  }

  /// Set selected application
  void setSelectedApplication(LeaseApplication? application) {
    _selectedApplication.value = application;
  }

  /// Clear selected application
  void clearSelectedApplication() {
    _selectedApplication.value = null;
  }

  /// Refresh data
  Future<void> refreshApplications(String userId) async {
    _currentPage.value = 1;
    _hasMoreData.value = true;
    await fetchMyApplications(userId);
  }
}
