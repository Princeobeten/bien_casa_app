import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../models/campaign/campaign.dart';
import '../../../../../services/account_status_service.dart';
import '../../../../../services/api/campaign_service.dart';
import '../../../../../services/dio_client.dart';

/// Read-only campaign view. Uses the same step structure as Create Campaign.
class CampaignViewPage extends StatefulWidget {
  const CampaignViewPage({super.key});

  @override
  State<CampaignViewPage> createState() => _CampaignViewPageState();
}

class _CampaignViewPageState extends State<CampaignViewPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _step1;
  Map<String, dynamic>? _step2;
  Map<String, dynamic>? _step3;
  Map<String, dynamic>? _step4;
  Map<String, dynamic>? _biodata;
  List<dynamic> _biodataFields = [];
  List<dynamic> _creatorHouseFeaturesFields = [];
  List<dynamic> _matePersonalityFields = [];
  List<dynamic> _apartmentPreferenceFields = [];

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  Future<void> _loadCampaignData() async {
    final campaign = Get.arguments as Campaign?;
    if (campaign?.id == null) {
      setState(() {
        _loading = false;
        _error = 'Campaign not found';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = campaign!.id!;

      // Fetch step data and datafield definitions in parallel
      final results = await Future.wait([
        CampaignService.getCampaign(id),
        CampaignService.getCampaignStepData(step: 'step1', campaignId: id),
        CampaignService.getCampaignStepData(step: 'step2', campaignId: id),
        CampaignService.getCampaignStepData(step: 'step3', campaignId: id),
        CampaignService.getCampaignStepData(step: 'step4', campaignId: id),
        AccountStatusService.getProfile(),
        DioClient.get('misc/datafields/biodata'),
        DioClient.get('misc/datafields/creatorHouseFeatures'),
        DioClient.get('misc/datafields/matePersonalityTraitPreference'),
        DioClient.get('misc/datafields/apartmentPreference'),
      ]);

      final campaignRes = results[0] as Map<String, dynamic>;
      final step1Res = results[1] as Map<String, dynamic>;
      final step2Res = results[2] as Map<String, dynamic>;
      final step3Res = results[3] as Map<String, dynamic>;
      final step4Res = results[4] as Map<String, dynamic>;
      final profileRes = results[5] as Map<String, dynamic>;
      final biodataFieldsRes = results[6] as Map<String, dynamic>;
      final creatorHouseRes = results[7] as Map<String, dynamic>;
      final matePersonalityRes = results[8] as Map<String, dynamic>;
      final apartmentRes = results[9] as Map<String, dynamic>;

      Map<String, dynamic>? step1Data = campaignRes['data'] is Map ? Map<String, dynamic>.from(campaignRes['data'] as Map) : null;
      step1Data ??= step1Res['data'] is Map ? Map<String, dynamic>.from(step1Res['data'] as Map) : null;
      final step2Data = step2Res['data'] is Map ? Map<String, dynamic>.from(step2Res['data'] as Map) : null;
      final step3Data = step3Res['data'] is Map ? Map<String, dynamic>.from(step3Res['data'] as Map) : null;
      final step4Data = step4Res['data'] is Map ? Map<String, dynamic>.from(step4Res['data'] as Map) : null;

      Map<String, dynamic>? biodataMap;
      final raw = profileRes['data'];
      if (raw is Map) {
        final record = raw['biodataRecord'];
        if (record is Map && record['bioData'] is Map) {
          biodataMap = Map<String, dynamic>.from(record['bioData'] as Map);
        }
      }

      List<dynamic> biodataFields = [];
      if (biodataFieldsRes['data'] is List) {
        biodataFields = (biodataFieldsRes['data'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        biodataFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
      }

      List<dynamic> creatorHouseFields = [];
      if (creatorHouseRes['data'] is List) {
        creatorHouseFields = (creatorHouseRes['data'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        creatorHouseFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
      }

      List<dynamic> matePersonalityFields = [];
      if (matePersonalityRes['data'] is List) {
        matePersonalityFields = (matePersonalityRes['data'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        matePersonalityFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
      }

      List<dynamic> apartmentFields = [];
      if (apartmentRes['data'] is List) {
        apartmentFields = (apartmentRes['data'] as List).map((e) => e is Map ? Map<String, dynamic>.from(e) : e).toList();
        apartmentFields.sort((a, b) => ((a['sortOrder'] ?? 0) as int).compareTo((b['sortOrder'] ?? 0) as int));
      }

      setState(() {
        _step1 = step1Data;
        _step2 = step2Data;
        _step3 = step3Data;
        _step4 = step4Data;
        _biodata = biodataMap;
        _biodataFields = biodataFields;
        _creatorHouseFeaturesFields = creatorHouseFields;
        _matePersonalityFields = matePersonalityFields;
        _apartmentPreferenceFields = apartmentFields;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  bool get _creatorIsHomeOwner => _step1?['creatorIsHomeOwner'] == true;
  String get _goal => _step1?['goal']?.toString() ?? _step1?['campaignGoal']?.toString() ?? 'Flatmate';
  String get _budgetPlan {
    final p = _step1?['campaignBudgetPlan'] ?? (_step1?['budget'] is Map ? (_step1!['budget'] as Map)['plan'] : null);
    final s = p?.toString() ?? 'month';
    if (s == 'year') return 'Year';
    if (s == 'quarter') return 'Quarter';
    return 'Month';
  }

  String _formatNumber(dynamic n) {
    if (n == null) return '';
    final val = n is num ? n.toInt() : int.tryParse(n.toString());
    if (val == null) return n.toString();
    return val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    if (_campaign == null && !_loading) {
      return _buildErrorScaffold('Campaign not found');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Campaign Details',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _error != null
              ? _buildErrorBody()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(_campaign!.status ?? 'Active'),
                      const SizedBox(height: 24),

                      // Step 1: Basic Campaign Details (same as create flow)
                      _buildStepTitle('Basic Campaign Details', 'Max flatmates, city/area, budget, homeowner toggle'),
                      const SizedBox(height: 16),
                      _buildStep1Content(),

                      // Step 2: Homeowner Details
                      if (_creatorIsHomeOwner) ...[
                        const SizedBox(height: 32),
                        _buildStepTitle('Homeowner Details', 'Location and house features'),
                        const SizedBox(height: 16),
                        _buildStep2Content(),
                      ],

                      // Step 3: Your Profile
                      const SizedBox(height: 32),
                      _buildStepTitle('Your Profile', 'Your biodata'),
                      const SizedBox(height: 16),
                      _buildStep3Content(),

                      // Step 4: Preferred Flatmate Personality
                      const SizedBox(height: 32),
                      _buildStepTitle('Preferred Flatmate Personality', 'Personality traits, lifestyle, smoking & pets'),
                      const SizedBox(height: 16),
                      _buildStep4Content(),

                      // Step 5: Apartment Preference
                      const SizedBox(height: 32),
                      _buildStepTitle('Apartment Preference', _creatorIsHomeOwner ? 'Not applicable (homeowner)' : 'Location, budget, property type'),
                      const SizedBox(height: 16),
                      _buildStep5Content(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content() {
    final b = _step1?['budget'] is Map ? _step1!['budget'] as Map : null;
    final minB = b?['min'] ?? _step1?['campaignStartBudget'];
    final maxB = b?['max'] ?? _step1?['campaignEndBudget'];
    final cityInfo = _step1?['campaignCityTownInfo'] is Map ? _step1!['campaignCityTownInfo'] as Map : null;
    final areaInfo = _step1?['campaignAreaInfo'] is Map ? _step1!['campaignAreaInfo'] as Map : null;
    final cityName = cityInfo?['name'] ?? '';
    final areaName = areaInfo?['name'] ?? '';
    final cityTown = cityName.toString().isNotEmpty || areaName.toString().isNotEmpty
        ? '${cityName ?? ''}${cityName != null && areaName != null ? ', ' : ''}${areaName ?? ''}'
        : (_campaign?.city ?? '');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Goal'),
          _buildReadOnlyField('', _goal),
          _buildSectionTitle('Budget Range (NGN)'),
          _buildReadOnlyField('', 'NGN ${_formatNumber(minB)} to NGN ${_formatNumber(maxB)}'),
          _buildSectionTitle('Budget Plan'),
          _buildReadOnlyField('', _budgetPlan),
          _buildSectionTitle('Max Number of Flatmates'),
          _buildReadOnlyField('Maximum flatmates', _campaign?.noOfFlatmates?.toString() ?? _step1?['maxNumberOfFlatmates']?.toString() ?? '-'),
          _buildSectionTitle('City/Town'),
          _buildReadOnlyField('', cityTown),
          _buildSectionTitle('I am a Home Owner'),
          _buildReadOnlyField('', _creatorIsHomeOwner ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildStep2Content() {
    final data = _step2 ?? _step1 ?? {};
    final location = data['location'] ?? data['creatorNeighboringLocation'] ?? '';
    final cityInfo = data['creatorCityTownInfo'] is Map ? data['creatorCityTownInfo'] as Map : null;
    final areaInfo = data['creatorAreaInfo'] is Map ? data['creatorAreaInfo'] as Map : null;
    final cityName = cityInfo?['name'] ?? '';
    final areaName = areaInfo?['name'] ?? '';
    final homeCity = cityName.toString().isNotEmpty || areaName.toString().isNotEmpty
        ? '${cityName ?? ''}${cityName != null && areaName != null ? ', ' : ''}${areaName ?? ''}'
        : '';
    final features = data['creatorHouseFeatures'] is Map ? data['creatorHouseFeatures'] as Map : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Neighboring location'),
          _buildReadOnlyField('', location.toString()),
          _buildSectionTitle('Your home city / area (optional)'),
          _buildReadOnlyField('', homeCity.trim().isEmpty ? '-' : homeCity.trim()),
          _buildSectionTitle('House features'),
          ..._creatorHouseFeaturesFields.map((field) {
            final skey = field['skey']?.toString() ?? '';
            final name = field['name']?.toString() ?? skey;
            final dataType = field['fieldDataType']?.toString() ?? 'text';
            if (dataType == 'file') return const SizedBox.shrink();
            dynamic value = features?[skey];
            if (value == null) return const SizedBox.shrink();
            final str = value is List ? value.join(', ') : value.toString();
            if (str.isEmpty) return const SizedBox.shrink();
            return _buildReadOnlyField(name, str);
          }),
        ],
      ),
    );
  }

  Widget _buildStep3Content() {
    if (_biodata == null || _biodata!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No biodata provided',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontFamily: 'ProductSans', fontSize: 18, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Text(
            'This information helps us match you better',
            style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ..._biodataFields.map((field) {
            final skey = field['skey']?.toString();
            if (skey == null || skey.isEmpty) return const SizedBox.shrink();
            final value = _biodata![skey];
            if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
            String displayValue = value.toString();
            if (field['fieldDataType']?.toString() == 'date') {
              try {
                displayValue = DateFormat('dd/MM/yyyy').format(DateTime.parse(value.toString()));
              } catch (_) {}
            }
            final label = field['name']?.toString() ?? skey;
            return _buildReadOnlyField(label, displayValue);
          }),
        ],
      ),
    );
  }

  Widget _buildStep4Content() {
    if (_goal != 'Flatmate') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              'No additional preferences needed',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'ProductSans'),
            ),
          ),
        ),
      );
    }
    final pref = _step3?['matePersonalityTraitPreference'] is Map
        ? _step3!['matePersonalityTraitPreference'] as Map
        : _step3;
    if (pref == null || pref.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No preferences set',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Preferred Flatmate Personality'),
          ..._matePersonalityFields.map((field) {
            final skey = field['skey']?.toString() ?? '';
            final name = field['name']?.toString() ?? skey;
            final value = pref[skey];
            if (value == null) return const SizedBox.shrink();
            final str = value is List ? value.join(', ') : value.toString();
            if (str.isEmpty) return const SizedBox.shrink();
            return _buildReadOnlyField(name, str);
          }),
        ],
      ),
    );
  }

  Widget _buildStep5Content() {
    if (_creatorIsHomeOwner) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "You're a homeowner — apartment preference is not required.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700], fontFamily: 'ProductSans'),
            ),
          ),
        ),
      );
    }
    final ap = _step4?['apartmentPreference'] is Map ? _step4!['apartmentPreference'] as Map : _step4;
    if (ap == null || ap.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'No apartment preferences set',
          style: TextStyle(fontFamily: 'ProductSans', fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Apartment Preference'),
          if (ap['location'] != null) _buildReadOnlyField('Preferred Location', ap['location'].toString()),
          if (ap['budgetMin'] != null) _buildReadOnlyField('Minimum Budget', 'NGN ${_formatNumber(ap['budgetMin'])}'),
          if (ap['budgetMax'] != null) _buildReadOnlyField('Maximum Budget', 'NGN ${_formatNumber(ap['budgetMax'])}'),
          ..._apartmentPreferenceFields.map((field) {
            final skey = field['skey']?.toString() ?? '';
            if (skey == 'location' || skey == 'budgetMin' || skey == 'budgetMax') return const SizedBox.shrink();
            final name = field['name']?.toString() ?? skey;
            final value = ap[skey];
            if (value == null) return const SizedBox.shrink();
            return _buildReadOnlyField(name, value.toString());
          }),
        ],
      ),
    );
  }

  Campaign? get _campaign => Get.arguments as Campaign?;

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: _statusColor(status)),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _statusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScaffold(String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Get.back()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(child: Text(message, style: const TextStyle(fontFamily: 'ProductSans'))),
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Failed to load campaign',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontFamily: 'ProductSans'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadCampaignData,
              child: const Text('Retry', style: TextStyle(fontFamily: 'ProductSans')),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'inactive':
      case 'paused':
        return Colors.orange.shade600;
      case 'closed':
      case 'completed':
        return Colors.red.shade600;
      case 'draft':
        return Colors.blueGrey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
