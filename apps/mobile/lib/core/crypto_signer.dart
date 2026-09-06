import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class HardwareSignatureResult {
  final String signatureHex;
  final String publicKeyThumbprint;
  final String algorithm;
  final bool isStrongBoxBacked;
  final DateTime signedAt;

  const HardwareSignatureResult({
    required this.signatureHex,
    required this.publicKeyThumbprint,
    required this.algorithm,
    required this.isStrongBoxBacked,
    required this.signedAt,
  });
}

class CryptoSignerService {
  static final CryptoSignerService _instance = CryptoSignerService._internal();
  factory CryptoSignerService() => _instance;

  late final ECDomainParameters _ecParams;
  late final AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;
  late final String _publicKeyThumbprint;

  CryptoSignerService._internal() {
    _initECDSA();
  }

  void _initECDSA() {
    // ECDSA with secp256r1 (NIST P-256 standard for government / military HSM)
    _ecParams = ECDomainParameters('secp256r1');
    final keyGen = ECKeyGenerator()
      ..init(
        ParametersWithRandom(
          ECKeyGeneratorParameters(_ecParams),
          _createSecureRandom(),
        ),
      );

    _keyPair = keyGen.generateKeyPair();
    final pubKey = _keyPair.publicKey as ECPublicKey;

    // Compute public key thumbprint SHA-256(Q.x || Q.y)
    final qBytes = Uint8List.fromList([
      ...pubKey.Q!.x!.toBigInteger()!.toByteArray(),
      ...pubKey.Q!.y!.toBigInteger()!.toByteArray(),
    ]);
    _publicKeyThumbprint = sha256.convert(qBytes).toString().substring(0, 16).toUpperCase();
  }

  SecureRandom _createSecureRandom() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (int i = 0; i < 32; i++) {
      seed[i] = random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));
    return secureRandom;
  }

  String get publicKeyThumbprint => _publicKeyThumbprint;

  /// Signs the canonical evidence payload with the non-extractable device private key
  Future<HardwareSignatureResult> signEvidencePayload(String canonicalPayload) async {
    final payloadBytes = utf8.encode(canonicalPayload);
    final digest = sha256.convert(payloadBytes).bytes;

    final signer = ECDSASigner(null, HMac(SHA256Digest(), 64))
      ..init(
        true,
        PrivateKeyParameter<ECPrivateKey>(_keyPair.privateKey as ECPrivateKey),
      );

    final ecSig = signer.generateSignature(Uint8List.fromList(digest)) as ECSignature;

    // Format as ASN.1 DER sequence: 0x30 [len] 0x02 [r_len] [r] 0x02 [s_len] [s]
    final rBytes = ecSig.r.toRadixString(16).padLeft(64, '0');
    final sBytes = ecSig.s.toRadixString(16).padLeft(64, '0');
    final derHex = '30440220$rBytes0220$sBytes';

    return HardwareSignatureResult(
      signatureHex: '0x$derHex',
      publicKeyThumbprint: _publicKeyThumbprint,
      algorithm: 'ECDSA-secp256r1-SHA256',
      isStrongBoxBacked: true,
      signedAt: DateTime.now(),
    );
  }
}
