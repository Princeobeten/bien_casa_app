import '../../models/campaign/campaign.dart';
import 'api_client.dart';

/// CampaignService - Campaign operations
class CampaignService {
  final ApiClient _apiClient;

  CampaignService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ========== Campaign CRUD ==========

  /// Get all campaigns (with optional goal filter)
  /// Matches: GET /campaign?goal=Flatmate
  Future<List<Campaign>> getCampaigns({
    String? goal, // 'Flatmate', 'Flat', 'Short-stay'
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (goal != null) queryParams['goal'] = goal;

    final response = await _apiClient.get(
      '/campaign',
      queryParams: queryParams,
    );

    final List<dynamic> data = response['campaigns'] as List<dynamic>;
    return data.map((json) => Campaign.fromJson(json)).toList();
  }

  /// Get user's campaigns
  /// Matches: GET /campaign/user
  Future<List<Campaign>> getUserCampaigns() async {
    final response = await _apiClient.get('/campaign/user');
    final List<dynamic> data = response['campaigns'] as List<dynamic>;
    return data.map((json) => Campaign.fromJson(json)).toList();
  }

  /// Create campaign
  /// Matches: POST /campaign/create
  Future<Campaign> createCampaign(Map<String, dynamic> campaignData) async {
    try {
      print('CampaignService: Calling API with data: $campaignData');
      final response = await _apiClient.post(
        '/campaign/create',
        body: campaignData,
      );
      print('CampaignService: API response: $response');
      return Campaign.fromJson(response['campaign']);
    } catch (e) {
      print('CampaignService: Error creating campaign: $e');
      rethrow;
    }
  }

  /// Update campaign
  /// Matches: PATCH /campaign/update
  Future<Campaign> updateCampaign(Map<String, dynamic> campaignData) async {
    final response = await _apiClient.patch(
      '/campaign/update',
      body: campaignData,
    );
    return Campaign.fromJson(response['campaign']);
  }

  /// Delete campaign
  /// Matches: DELETE /campaign/delete/{id}
  Future<void> deleteCampaign(int id) async {
    await _apiClient.delete('/campaign/delete/$id');
  }

  // ========== Campaign Applications ==========

  /// Apply to a campaign
  /// Matches: POST /campaign/applications/{id}
  Future<void> applyToCampaign(int campaignId) async {
    await _apiClient.post('/campaign/applications/$campaignId');
  }

  /// Get user campaign applications
  /// Matches: GET /campaign/applications
  Future<List<dynamic>> getCampaignApplications() async {
    final response = await _apiClient.get('/campaign/applications');
    return response['applications'] as List<dynamic>;
  }

  /// Accept or reject campaign application
  /// Matches: PUT /campaign/applications/respond
  Future<void> respondToApplication(int applicationId, String status) async {
    await _apiClient.put(
      '/campaign/applications/respond',
      body: {
        'applicationId': applicationId,
        'status': status, // 'ACCEPTED' or 'REJECTED'
      },
    );
  }

  /// Create campaign group chat
  /// Matches: POST /campaign/{id}/create-chat
  Future<void> createCampaignGroupChat(int campaignId) async {
    await _apiClient.post('/campaign/$campaignId/create-chat');
  }

}
