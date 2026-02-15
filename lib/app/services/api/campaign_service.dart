import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../dio_client.dart';

/// Campaign API service using DioClient (auth + refresh).
/// All endpoints return Map with 'message' and 'data' (and 'pagination' where applicable).
class CampaignService {
  static Future<Map<String, dynamic>> _handleResponse(
      Future<Map<String, dynamic>> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Campaign API error: $e');
        print('❌ Response statusCode: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      final statusCode = e.response?.statusCode;
      String? message;
      if (statusCode != null && statusCode >= 500) {
        message = 'Server temporarily unavailable. Please try again in a moment.';
      } else if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        message = data['message']?.toString();
        if (message == null && data['errors'] is List) {
          final parts = (data['errors'] as List)
              .map((x) => x is Map ? '${x['field']}: ${x['message']}' : x.toString())
              .toList();
          if (parts.isNotEmpty) message = parts.join('; ');
        }
      }
      throw Exception(message ?? e.message ?? 'Request failed');
    }
  }

  // ─── Create / Update steps ─────────────────────────────────────────────────

  /// PUT /campaign/create/step1 — Update campaign step 1 (basic info) for existing draft.
  static Future<Map<String, dynamic>> updateStep1({
    required int campaignId,
    required int maxNumberOfFlatmates,
    required int campaignCityTown,
    required int campaignArea,
    required num campaignStartBudget,
    required num campaignEndBudget,
    String campaignBudgetPlan = 'month',
    bool creatorIsHomeOwner = false,
  }) async {
    return _handleResponse(() async {
      return DioClient.put('campaign/create/step1', data: {
        'campaignId': campaignId,
        'maxNumberOfFlatmates': maxNumberOfFlatmates,
        'campaignCityTown': campaignCityTown,
        'campaignArea': campaignArea,
        'campaignStartBudget': campaignStartBudget,
        'campaignEndBudget': campaignEndBudget,
        'campaignBudgetPlan': campaignBudgetPlan,
        'creatorIsHomeOwner': creatorIsHomeOwner,
      });
    });
  }

  /// POST /campaign/create/step1 — Create campaign step 1 (basic info). Returns campaign in Draft (201).
  /// Backend expects: campaignCityTown (city ID, number), campaignArea (area ID, number).
  static Future<Map<String, dynamic>> createStep1({
    required int maxNumberOfFlatmates,
    required int campaignCityTown,
    required int campaignArea,
    required num campaignStartBudget,
    required num campaignEndBudget,
    String campaignBudgetPlan = 'month',
    bool creatorIsHomeOwner = false,
  }) async {
    return _handleResponse(() async {
      return DioClient.post('campaign/create/step1', data: {
        'maxNumberOfFlatmates': maxNumberOfFlatmates,
        'campaignCityTown': campaignCityTown,
        'campaignArea': campaignArea,
        'campaignStartBudget': campaignStartBudget,
        'campaignEndBudget': campaignEndBudget,
        'campaignBudgetPlan': campaignBudgetPlan,
        'creatorIsHomeOwner': creatorIsHomeOwner,
      });
    });
  }

  /// PUT /campaign/create/step2 — Update step 2 (homeowner details). creatorCityTown, creatorArea, location, creatorHouseFeatures.
  static Future<Map<String, dynamic>> updateStep2({
    required int campaignId,
    int? creatorCityTown,
    int? creatorArea,
    String? location,
    Map<String, dynamic>? creatorHouseFeatures,
  }) async {
    return _handleResponse(() async {
      final body = <String, dynamic>{'campaignId': campaignId};
      if (creatorCityTown != null) body['creatorCityTown'] = creatorCityTown;
      if (creatorArea != null) body['creatorArea'] = creatorArea;
      if (location != null) body['location'] = location;
      if (creatorHouseFeatures != null && creatorHouseFeatures.isNotEmpty) body['creatorHouseFeatures'] = creatorHouseFeatures;
      if (kDebugMode) {
        print('📤 Campaign step2 payload: $body');
      }
      final response = await DioClient.put('campaign/create/step2', data: body);
      if (kDebugMode) {
        print('📥 Campaign step2 response: $response');
      }
      return response;
    });
  }

  /// Step3 keys from GET /misc/datafields/matePersonalityTraitPreference: personalityTraits, lifestyle, smoking, pets.
  static const Set<String> _step3AllowedKeys = {'personalityTraits', 'lifestyle', 'smoking', 'pets'};

  /// PUT /campaign/create/step3 — Update step 3 (Personality Preferences).
  /// Sends keys from datafields; values as-is (string or List for check-type).
  static Future<Map<String, dynamic>> updateStep3({
    required int campaignId,
    required Map<String, dynamic> matePersonalityTraitPreference,
  }) async {
    final filtered = <String, dynamic>{};
    for (final key in matePersonalityTraitPreference.keys) {
      if (!_step3AllowedKeys.contains(key)) continue;
      final v = matePersonalityTraitPreference[key];
      if (v == null) continue;
      if (v is List) {
        if (v.isEmpty) continue;
        filtered[key] = v.map((e) => e.toString()).toList();
      } else {
        final s = v.toString().trim();
        if (s.isEmpty) continue;
        filtered[key] = s;
      }
    }
    final body = {
      'campaignId': campaignId,
      'matePersonalityTraitPreference': filtered,
    };
    return _handleResponse(() async {
      if (kDebugMode) {
        print('📤 Campaign step3 payload: $body');
      }
      final response = await DioClient.put('campaign/create/step3', data: body);
      if (kDebugMode) {
        print('📥 Campaign step3 response: $response');
      }
      return response;
    });
  }

  /// PUT /campaign/create/step4 — Update step 4 (apartment preferences, non-homeowner only).
  static Future<Map<String, dynamic>> updateStep4({
    required int campaignId,
    required Map<String, dynamic> apartmentPreference,
  }) async {
    return _handleResponse(() async {
      return DioClient.put('campaign/create/step4', data: {
        'campaignId': campaignId,
        'apartmentPreference': apartmentPreference,
      });
    });
  }

  /// POST /campaign/create/initiatePublishCampaign — Publish campaign (step 5, N1,000 fee).
  /// paymentMethod: 'wallet' or 'external'. Optional: walletPin; for biometric set biometric=true, deviceId, signature.
  static Future<Map<String, dynamic>> initiatePublishCampaign({
    required int campaignId,
    required String paymentMethod,
    String? walletPin,
    bool biometric = false,
    String? deviceId,
    String? signature,
  }) async {
    return _handleResponse(() async {
      final body = <String, dynamic>{
        'campaignId': campaignId,
        'paymentMethod': paymentMethod,
      };
      if (walletPin != null && walletPin.isNotEmpty) body['walletPin'] = walletPin;
      if (biometric && deviceId != null && signature != null) {
        body['biometric'] = true;
        body['deviceId'] = deviceId;
        body['signature'] = signature;
      }
      return DioClient.post('campaign/create/initiatePublishCampaign', data: body);
    });
  }

  // ─── Campaign CRUD ─────────────────────────────────────────────────────────

  /// GET /campaign/{id} — Get single campaign (includes isOwner for current user).
  static Future<Map<String, dynamic>> getCampaign(int id) async {
    return _handleResponse(() => DioClient.get('campaign/$id'));
  }

  /// DELETE /campaign/{id} — Delete campaign (creator only).
  static Future<Map<String, dynamic>> deleteCampaign(int id) async {
    return _handleResponse(() => DioClient.delete('campaign/$id'));
  }

  /// GET /campaign/data/{step}/{id} — Get campaign data for a specific step (step1–step5). Creator only.
  static Future<Map<String, dynamic>> getCampaignStepData({
    required String step,
    required int campaignId,
  }) async {
    return _handleResponse(
      () => DioClient.get('campaign/data/$step/$campaignId'),
    );
  }

  /// GET /campaign/all — Get all campaigns with filters and pagination.
  static Future<Map<String, dynamic>> getAllCampaigns({
    String? status,
    int? cityTownId,
    int? areaId,
    num? budgetMin,
    num? budgetMax,
    String? budgetPlan,
    int? maxFlatmates,
    bool? isAcceptingRequest,
    int page = 1,
    int limit = 20,
  }) async {
    return _handleResponse(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) query['status'] = status;
      if (cityTownId != null) query['cityTownId'] = cityTownId;
      if (areaId != null) query['areaId'] = areaId;
      if (budgetMin != null) query['budgetMin'] = budgetMin;
      if (budgetMax != null) query['budgetMax'] = budgetMax;
      if (budgetPlan != null) query['budgetPlan'] = budgetPlan;
      if (maxFlatmates != null) query['maxFlatmates'] = maxFlatmates;
      if (isAcceptingRequest != null) query['isAcceptingRequest'] = isAcceptingRequest;
      return DioClient.get('campaign/all', queryParameters: query);
    });
  }

  /// GET /campaign/nearby — Get campaigns by location.
  static Future<Map<String, dynamic>> getNearbyCampaigns({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    return _handleResponse(() => DioClient.get(
          'campaign/nearby',
          queryParameters: {
            'latitude': latitude,
            'longitude': longitude,
            'radius': radiusKm,
          },
        ));
  }

  /// GET /campaign/user/my-campaigns — Get current user's campaigns with filters.
  static Future<Map<String, dynamic>> getMyCampaigns({
    String? status,
    int? cityTownId,
    int? areaId,
    num? budgetMin,
    num? budgetMax,
    String? budgetPlan,
    int? maxFlatmates,
    bool? isAcceptingRequest,
    int page = 1,
    int limit = 20,
  }) async {
    return _handleResponse(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) query['status'] = status;
      if (cityTownId != null) query['cityTownId'] = cityTownId;
      if (areaId != null) query['areaId'] = areaId;
      if (budgetMin != null) query['budgetMin'] = budgetMin;
      if (budgetMax != null) query['budgetMax'] = budgetMax;
      if (budgetPlan != null) query['budgetPlan'] = budgetPlan;
      if (maxFlatmates != null) query['maxFlatmates'] = maxFlatmates;
      if (isAcceptingRequest != null) query['isAcceptingRequest'] = isAcceptingRequest;
      return DioClient.get('campaign/user/my-campaigns', queryParameters: query);
    });
  }

  /// GET /campaign/user/unpublished — Get user's draft (unpublished) campaigns with pagination.
  /// Response per API doc: { "campaigns": [...], "pagination": {...} } (not "data").
  static Future<Map<String, dynamic>> getUnpublishedCampaigns({
    int page = 1,
    int limit = 20,
  }) async {
    return _handleResponse(() => DioClient.get(
          'campaign/user/unpublished',
          queryParameters: {'page': page, 'limit': limit},
        ));
  }

  // ─── Join & Flatmate requests ──────────────────────────────────────────────

  /// POST /campaign/join — Join a campaign (payment reference for N1,000 fee).
  static Future<Map<String, dynamic>> joinCampaign({
    required int campaignId,
    required String paymentReference,
  }) async {
    return _handleResponse(() => DioClient.post('campaign/join', data: {
          'campaignId': campaignId,
          'paymentReference': paymentReference,
        }));
  }

  /// GET /campaign/{id}/flatmate-requests — Get flatmate requests for a campaign (owner only).
  static Future<Map<String, dynamic>> getCampaignFlatmateRequests(
    int campaignId, {
    String? status,
    bool? isViewed,
    int page = 1,
    int limit = 20,
  }) async {
    return _handleResponse(() async {
      final query = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null) query['status'] = status;
      if (isViewed != null) query['isViewed'] = isViewed;
      return DioClient.get(
        'campaign/$campaignId/flatmate-requests',
        queryParameters: query.isEmpty ? null : query,
      );
    });
  }

  /// GET /campaign/my-requests/all — Get current user's flatmate requests.
  static Future<Map<String, dynamic>> getMyFlatmateRequests() async {
    return _handleResponse(() => DioClient.get('campaign/my-requests/all'));
  }

  /// PUT /campaign/flatmate-request/{id}/view — Mark flatmate request as viewed (owner only).
  static Future<Map<String, dynamic>> markFlatmateRequestViewed(int requestId) async {
    return _handleResponse(() => DioClient.put('campaign/flatmate-request/$requestId/view'));
  }

  /// PUT /campaign/flatmate-request/status — Update request status (Declined / Matched). Owner only.
  static Future<Map<String, dynamic>> updateFlatmateRequestStatus({
    required int requestId,
    required String status,
    String? note,
  }) async {
    return _handleResponse(() => DioClient.put('campaign/flatmate-request/status', data: {
          'requestId': requestId,
          'status': status,
          if (note != null) 'note': note,
        }));
  }

  /// PUT /campaign/flatmate-request/{id}/withdraw — Withdraw own flatmate request.
  static Future<Map<String, dynamic>> withdrawFlatmateRequest(int requestId) async {
    return _handleResponse(() => DioClient.put('campaign/flatmate-request/$requestId/withdraw'));
  }

  // ─── Campaign houses ───────────────────────────────────────────────────────

  /// POST /campaign/house/add — Add house to campaign.
  static Future<Map<String, dynamic>> addHouseToCampaign({
    required int campaignId,
    required int houseLeaseId,
  }) async {
    return _handleResponse(() => DioClient.post('campaign/house/add', data: {
          'campaignId': campaignId,
          'houseLeaseId': houseLeaseId,
        }));
  }

  /// DELETE /campaign/house/{id} — Remove house from campaign.
  static Future<Map<String, dynamic>> removeHouseFromCampaign(int campaignHouseId) async {
    return _handleResponse(() => DioClient.delete('campaign/house/$campaignHouseId'));
  }

  /// PUT /campaign/house/approve — Approve or disapprove campaign house (owner only).
  static Future<Map<String, dynamic>> approveCampaignHouse({
    required int campaignHouseId,
    required bool isApproved,
  }) async {
    return _handleResponse(() => DioClient.put('campaign/house/approve', data: {
          'campaignHouseId': campaignHouseId,
          'isApproved': isApproved,
        }));
  }

  // ─── Other ────────────────────────────────────────────────────────────────

  /// POST /campaign/{id}/create-chat — Create campaign group chat (creator only).
  static Future<Map<String, dynamic>> createCampaignChat(int campaignId) async {
    return _handleResponse(() => DioClient.post('campaign/$campaignId/create-chat'));
  }

  /// POST /campaign/{id}/recommendations — Get house recommendations for campaign.
  static Future<Map<String, dynamic>> getCampaignRecommendations(int campaignId) async {
    return _handleResponse(() => DioClient.post('campaign/$campaignId/recommendations'));
  }
}
