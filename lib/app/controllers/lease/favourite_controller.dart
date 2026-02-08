import 'package:get/get.dart';
import '../../models/lease/favourite.dart';
import '../../services/api/favourite_service.dart';
import '../../services/api/api_exception.dart';

/// FavouriteController - Manages user favorites
class FavouriteController extends GetxController {
  final FavouriteService _favouriteService = FavouriteService();

  final RxList<Favourite> _favourites = <Favourite>[].obs;
  final RxSet<String> _favouriteIds = <String>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<Favourite> get favourites => _favourites;
  Set<String> get favouriteIds => _favouriteIds;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Fetch user's favourites
  Future<void> fetchFavourites(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final favourites = await _favouriteService.getFavourites(userId);
      _favourites.assignAll(favourites);

      // Update favourite IDs set for quick lookup
      _favouriteIds.clear();
      _favouriteIds.addAll(favourites.map((f) => f.houseLeaseId));
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

  /// Add to favourites
  Future<bool> addFavourite(String userId, String houseLeaseId) async {
    try {
      final favourite = await _favouriteService.addFavourite(
        userId,
        houseLeaseId,
      );
      _favourites.insert(0, favourite);
      _favouriteIds.add(houseLeaseId);

      Get.snackbar(
        'Success',
        'Added to favorites',
        snackPosition: SnackPosition.TOP,
      );
      return true;
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

  /// Remove from favourites
  Future<bool> removeFavourite(String id, String houseLeaseId) async {
    try {
      await _favouriteService.removeFavourite(id);
      _favourites.removeWhere((f) => f.id == id);
      _favouriteIds.remove(houseLeaseId);

      Get.snackbar(
        'Success',
        'Removed from favorites',
        snackPosition: SnackPosition.TOP,
      );
      return true;
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

  /// Toggle favourite
  Future<bool> toggleFavourite(String userId, String houseLeaseId) async {
    try {
      final isFavourited = await _favouriteService.toggleFavourite(
        userId,
        houseLeaseId,
      );

      if (isFavourited) {
        // Added to favourites - refresh list
        await fetchFavourites(userId);
      } else {
        // Removed from favourites
        _favourites.removeWhere((f) => f.houseLeaseId == houseLeaseId);
        _favouriteIds.remove(houseLeaseId);
      }

      return isFavourited;
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

  /// Check if property is favourited
  bool isFavourited(String houseLeaseId) {
    return _favouriteIds.contains(houseLeaseId);
  }

  /// Get favourite by house lease ID
  Favourite? getFavouriteByHouseLeaseId(String houseLeaseId) {
    try {
      return _favourites.firstWhere((f) => f.houseLeaseId == houseLeaseId);
    } catch (e) {
      return null;
    }
  }

  /// Clear all favourites (local only)
  void clearFavourites() {
    _favourites.clear();
    _favouriteIds.clear();
  }
}
