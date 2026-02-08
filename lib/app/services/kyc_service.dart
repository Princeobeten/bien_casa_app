import 'package:get_storage/get_storage.dart';

class KYCService {
  static final KYCService _instance = KYCService._internal();
  factory KYCService() => _instance;
  KYCService._internal();

  final _storage = GetStorage();
  static const String _kycKey = 'user_nin';
  static const String _kycStatusKey = 'kyc_completed';

  // Save NIN to local storage
  Future<void> saveNIN(String nin) async {
    await _storage.write(_kycKey, nin);
    await _storage.write(_kycStatusKey, true);
    print('NIN saved to local storage: $nin');
  }

  // Get NIN from local storage
  String? getNIN() {
    return _storage.read(_kycKey);
  }

  // Check if KYC is completed
  bool isKYCCompleted() {
    final nin = _storage.read(_kycKey);
    final status = _storage.read(_kycStatusKey) ?? false;
    return nin != null && nin.toString().isNotEmpty && status;
  }

  // Clear KYC data (for testing/logout)
  Future<void> clearKYC() async {
    await _storage.remove(_kycKey);
    await _storage.remove(_kycStatusKey);
    print('KYC data cleared from local storage');
  }

  // Get KYC status message
  String getKYCStatusMessage() {
    if (isKYCCompleted()) {
      return 'KYC Verified';
    } else {
      return 'KYC Pending';
    }
  }
}
