import '../../models/lease/favourite.dart';
import 'api_client.dart';
import 'api_config.dart';

/// FavouriteService - Favorites management
class FavouriteService {
  final ApiClient _apiClient;

  FavouriteService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get user's favourites
  Future<List<Favourite>> getFavourites(String userId) async {
    final response = await _apiClient.get(
      ApiConfig.favourites,
      queryParams: {'userId': userId},
    );

    final List<dynamic> data = response['data'] as List<dynamic>;
    return data.map((json) => Favourite.fromJson(json)).toList();
  }

  /// Add to favourites
  Future<Favourite> addFavourite(String userId, String houseLeaseId) async {
    final response = await _apiClient.post(
      ApiConfig.favourites,
      body: {
        'userId': userId,
        'houseLeaseId': houseLeaseId,
      },
    );
    return Favourite.fromJson(response['data']);
  }

  /// Remove from favourites
  Future<void> removeFavourite(String id) async {
    await _apiClient.delete('${ApiConfig.favourites}/$id');
  }

  /// Check if property is favourited
  Future<bool> isFavourited(String userId, String houseLeaseId) async {
    final favourites = await getFavourites(userId);
    return favourites.any((fav) => fav.houseLeaseId == houseLeaseId);
  }

  /// Toggle favourite
  Future<bool> toggleFavourite(String userId, String houseLeaseId) async {
    final favourites = await getFavourites(userId);
    final existing = favourites.firstWhere(
      (fav) => fav.houseLeaseId == houseLeaseId,
      orElse: () => Favourite(
        id: '',
        userId: '',
        houseLeaseId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (existing.id.isNotEmpty) {
      await removeFavourite(existing.id);
      return false;
    } else {
      await addFavourite(userId, houseLeaseId);
      return true;
    }
  }
}
