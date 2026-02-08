import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';
import 'wallet_service.dart';

/// Handles device ID, RSA keypair storage, and biometric auth for wallet transfers.
class BiometricService {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
  static const _keyDeviceId = 'biometric_device_id';
  static const _keyPrivateKeyPem = 'biometric_private_key_pem';
  static const _keyPublicKeyPem = 'biometric_public_key_pem';

  static final _deviceInfo = DeviceInfoPlugin();
  static final _localAuth = LocalAuthentication();

  /// Returns a stable device identifier for this device.
  static Future<String> getDeviceId() async {
    try {
      final stored = await _storage.read(key: _keyDeviceId);
      if (stored != null && stored.isNotEmpty) {
        if (kDebugMode) print('📱 BiometricService deviceId: $stored');
        return stored;
      }

      String id;
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await _deviceInfo.androidInfo;
        id = android.id; // androidId is stable per app install
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = await _deviceInfo.iosInfo;
        id = ios.identifierForVendor ?? 'ios-${ios.utsname.machine}-${DateTime.now().millisecondsSinceEpoch}';
      } else {
        id = 'device-${DateTime.now().millisecondsSinceEpoch}';
      }
      final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9\-_]'), '-');
      await _storage.write(key: _keyDeviceId, value: safeId);
      if (kDebugMode) print('📱 BiometricService deviceId: $safeId');
      return safeId;
    } catch (e) {
      if (kDebugMode) print('❌ BiometricService getDeviceId: $e');
      return 'device-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Whether device has biometric hardware and user can use it.
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Whether biometric is enabled for this device (from backend).
  static Future<bool> isBiometricEnabled() async {
    try {
      final deviceId = await getDeviceId();
      final res = await WalletService.checkBiometric(deviceId);
      return res['biometricSet'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ BiometricService isBiometricEnabled: $e');
      return false;
    }
  }

  /// Enable transfer with biometric: generate keypair, store keys, register with backend.
  static Future<void> enableBiometric() async {
    final deviceId = await getDeviceId();
    final pair = _generateKeyPair();
    final publicPem = _encodePublicKeyToPem(pair.publicKey);
    final privatePem = _encodePrivateKeyToPem(pair.privateKey);

    await _storage.write(key: _keyPublicKeyPem, value: publicPem);
    await _storage.write(key: _keyPrivateKeyPem, value: privatePem);

    await WalletService.enableBiometric(deviceId: deviceId, publicKey: publicPem);
  }

  /// Disable transfer with biometric: sign challenge and call disable, then clear keys.
  static Future<void> disableBiometric() async {
    final deviceId = await getDeviceId();
    final publicPem = await _storage.read(key: _keyPublicKeyPem);
    final privatePem = await _storage.read(key: _keyPrivateKeyPem);

    if (publicPem == null || publicPem.isEmpty || privatePem == null || privatePem.isEmpty) {
      await _clearKeys();
      return;
    }

    final challengeRes = await WalletService.getBiometricChallenge(deviceId);
    final rawChallenge = challengeRes['data']?['challenge'];
    // Backend may return challenge as number (e.g. 2) which causes radix-16 parse errors; normalize to string
    final challenge = rawChallenge == null ? '' : rawChallenge.toString();
    if (kDebugMode) {
      print('📤 DISABLE challenge raw: $rawChallenge (type: ${rawChallenge != null ? rawChallenge.runtimeType : 'null'}) normalized: "$challenge"');
    }
    if (challenge.isEmpty) throw Exception('No challenge received');

    final signature = await signChallenge(challenge);
    await WalletService.disableBiometric(deviceId: deviceId, publicKey: publicPem, signature: signature);
    await _clearKeys();
  }

  static Future<void> _clearKeys() async {
    await _storage.delete(key: _keyPrivateKeyPem);
    await _storage.delete(key: _keyPublicKeyPem);
  }

  /// Show system biometric prompt and return true if user authenticated.
  static Future<bool> authenticateWithBiometric({String reason = 'Verify to continue'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      if (kDebugMode) print('❌ BiometricService authenticate: $e');
      return false;
    }
  }

  /// Get challenge from backend, sign with stored private key, verify with backend. Returns true if valid.
  static Future<bool> verifyBiometricForTransaction() async {
    try {
      final deviceId = await getDeviceId();
      final privatePem = await _storage.read(key: _keyPrivateKeyPem);
      if (privatePem == null || privatePem.isEmpty) return false;

      final challengeRes = await WalletService.getBiometricChallenge(deviceId);
      final challenge = challengeRes['data']?['challenge'] as String? ?? '';
      if (challenge.isEmpty) return false;

      final signature = await signChallenge(challenge);
      final res = await WalletService.verifyBiometric(deviceId: deviceId, signature: signature);
      return res['data']?['valid'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ BiometricService verifyForTransaction: $e');
      return false;
    }
  }

  /// Sign a challenge string with stored private key (SHA256-RSA). Returns base64 signature.
  static Future<String> signChallenge(String challenge) async {
    final privatePem = await _storage.read(key: _keyPrivateKeyPem);
    if (privatePem == null || privatePem.isEmpty) throw Exception('No biometric key');

    final privateKey = _parsePrivateKeyFromPem(privatePem);
    final digest = SHA256Digest();
    // Pointycastle RSASigner expects digest OID as HEX, not dotted decimal (e.g. 2.16.840...)
    const sha256OidHex = '0609608648016503040201'; // DER AlgorithmIdentifier for SHA-256
    final signer = RSASigner(digest, sha256OidHex);
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final messageBytes = Uint8List.fromList(utf8.encode(challenge));
    final signature = signer.generateSignature(messageBytes);
    return base64.encode(signature.bytes);
  }

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateKeyPair() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();
    final seeds = List<int>.generate(32, (_) => random.nextInt(256));
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    final keyParams = RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);
    final params = ParametersWithRandom(keyParams, secureRandom);
    final generator = RSAKeyGenerator();
    generator.init(params);
    final pair = generator.generateKeyPair();
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(pair.publicKey as RSAPublicKey, pair.privateKey as RSAPrivateKey);
  }

  static Uint8List _decodePem(String pem) {
    const starts = ['-----BEGIN PUBLIC KEY-----', '-----BEGIN PRIVATE KEY-----'];
    const ends = ['-----END PUBLIC KEY-----', '-----END PRIVATE KEY-----'];
    for (final s in starts) {
      if (pem.startsWith(s)) pem = pem.substring(s.length);
    }
    for (final e in ends) {
      if (pem.endsWith(e)) pem = pem.substring(0, pem.length - e.length);
    }
    pem = pem.replaceAll('\n', '').replaceAll('\r', '');
    return Uint8List.fromList(base64.decode(pem));
  }

  /// Read BigInt from DER-encoded ASN.1 INTEGER (avoids asn1lib valueAsBigInteger radix-16 parse).
  static BigInt _asn1IntegerToBigInt(ASN1Integer asn1) {
    final enc = asn1.encodedBytes;
    if (enc.length < 2) return BigInt.zero;
    int valueStart = 2;
    int len = enc[1];
    if (len & 0x80 != 0) {
      final numLenBytes = len & 0x7f;
      if (enc.length < 2 + numLenBytes) return BigInt.zero;
      len = 0;
      for (var i = 0; i < numLenBytes; i++) len = (len << 8) | (enc[2 + i] & 0xff);
      valueStart = 2 + numLenBytes;
    }
    if (valueStart + len > enc.length) return BigInt.zero;
    BigInt n = BigInt.zero;
    for (var i = valueStart; i < valueStart + len; i++) {
      n = (n << 8) | BigInt.from(enc[i] & 0xff);
    }
    return n;
  }

  static RSAPrivateKey _parsePrivateKeyFromPem(String pem) {
    final bytes = _decodePem(pem);
    final parser = ASN1Parser(bytes);
    final top = parser.nextObject() as ASN1Sequence;
    final keyOctets = top.elements[2] as ASN1OctetString;
    final pkParser = ASN1Parser(keyOctets.contentBytes());
    final pkSeq = pkParser.nextObject() as ASN1Sequence;
    final modulus = _asn1IntegerToBigInt(pkSeq.elements[1] as ASN1Integer);
    final privateExponent = _asn1IntegerToBigInt(pkSeq.elements[3] as ASN1Integer);
    final p = _asn1IntegerToBigInt(pkSeq.elements[4] as ASN1Integer);
    final q = _asn1IntegerToBigInt(pkSeq.elements[5] as ASN1Integer);
    return RSAPrivateKey(modulus, privateExponent, p, q);
  }

  static String _encodePublicKeyToPem(RSAPublicKey key) {
    final algorithmSeq = ASN1Sequence();
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1])));
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0])));

    final publicKeySeq = ASN1Sequence();
    publicKeySeq.add(ASN1Integer(key.modulus!));
    publicKeySeq.add(ASN1Integer(key.exponent!));
    final bitString = ASN1BitString(Uint8List.fromList(publicKeySeq.encodedBytes));

    final topLevel = ASN1Sequence();
    topLevel.add(algorithmSeq);
    topLevel.add(bitString);
    final b64 = base64.encode(topLevel.encodedBytes);
    return '-----BEGIN PUBLIC KEY-----\n$b64\n-----END PUBLIC KEY-----';
  }

  static String _encodePrivateKeyToPem(RSAPrivateKey key) {
    final pubExp = BigInt.from(65537);
    final version = ASN1Integer(BigInt.zero);
    final algorithmSeq = ASN1Sequence();
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList([0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1])));
    algorithmSeq.add(ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0])));

    final privateKeySeq = ASN1Sequence();
    privateKeySeq.add(version);
    privateKeySeq.add(ASN1Integer(key.n ?? key.modulus!));
    privateKeySeq.add(ASN1Integer(pubExp));
    privateKeySeq.add(ASN1Integer(key.exponent ?? key.privateExponent!));
    privateKeySeq.add(ASN1Integer(key.p!));
    privateKeySeq.add(ASN1Integer(key.q!));
    final d = key.privateExponent ?? key.exponent!;
    final pk = key.p!;
    final qk = key.q!;
    privateKeySeq.add(ASN1Integer(d % (pk - BigInt.one)));
    privateKeySeq.add(ASN1Integer(d % (qk - BigInt.one)));
    privateKeySeq.add(ASN1Integer(qk.modInverse(pk)));

    final octetString = ASN1OctetString(Uint8List.fromList(privateKeySeq.encodedBytes));
    final topLevel = ASN1Sequence();
    topLevel.add(version);
    topLevel.add(algorithmSeq);
    topLevel.add(octetString);
    final b64 = base64.encode(topLevel.encodedBytes);
    return '-----BEGIN PRIVATE KEY-----\n$b64\n-----END PRIVATE KEY-----';
  }
}
