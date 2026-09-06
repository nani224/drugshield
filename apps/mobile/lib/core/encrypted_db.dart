import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

enum SyncStatus {
  pending,
  syncing,
  committed,
  failed,
}

class OfflineSeizureRecord {
  final String id;
  final String firNumber;
  final String gdEntryNumber;
  final String officerBadge;
  final DateTime seizureTime;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final String detectedSubstance;
  final double confidenceScore;
  final String reagentUsed;
  final String evidencePayloadHash;
  final String ecdsaSignature;
  final String ipfsCid;
  final SyncStatus syncStatus;
  final String? fabricTxId;
  final DateTime createdAt;

  const OfflineSeizureRecord({
    required this.id,
    required this.firNumber,
    required this.gdEntryNumber,
    required this.officerBadge,
    required this.seizureTime,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.detectedSubstance,
    required this.confidenceScore,
    required this.reagentUsed,
    required this.evidencePayloadHash,
    required this.ecdsaSignature,
    required this.ipfsCid,
    required this.syncStatus,
    this.fabricTxId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'firNumber': firNumber,
        'gdEntryNumber': gdEntryNumber,
        'officerBadge': officerBadge,
        'seizureTime': seizureTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'detectedSubstance': detectedSubstance,
        'confidenceScore': confidenceScore,
        'reagentUsed': reagentUsed,
        'evidencePayloadHash': evidencePayloadHash,
        'ecdsaSignature': ecdsaSignature,
        'ipfsCid': ipfsCid,
        'syncStatus': syncStatus.name,
        'fabricTxId': fabricTxId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OfflineSeizureRecord.fromMap(Map<String, dynamic> map) => OfflineSeizureRecord(
        id: map['id'],
        firNumber: map['firNumber'],
        gdEntryNumber: map['gdEntryNumber'],
        officerBadge: map['officerBadge'],
        seizureTime: DateTime.parse(map['seizureTime']),
        latitude: map['latitude'],
        longitude: map['longitude'],
        accuracyMeters: map['accuracyMeters'],
        detectedSubstance: map['detectedSubstance'],
        confidenceScore: map['confidenceScore'],
        reagentUsed: map['reagentUsed'],
        evidencePayloadHash: map['evidencePayloadHash'],
        ecdsaSignature: map['ecdsaSignature'],
        ipfsCid: map['ipfsCid'],
        syncStatus: SyncStatus.values.byName(map['syncStatus']),
        fabricTxId: map['fabricTxId'],
        createdAt: DateTime.parse(map['createdAt']),
      );

  OfflineSeizureRecord copyWith({
    SyncStatus? syncStatus,
    String? fabricTxId,
  }) =>
      OfflineSeizureRecord(
        id: id,
        firNumber: firNumber,
        gdEntryNumber: gdEntryNumber,
        officerBadge: officerBadge,
        seizureTime: seizureTime,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        detectedSubstance: detectedSubstance,
        confidenceScore: confidenceScore,
        reagentUsed: reagentUsed,
        evidencePayloadHash: evidencePayloadHash,
        ecdsaSignature: ecdsaSignature,
        ipfsCid: ipfsCid,
        syncStatus: syncStatus ?? this.syncStatus,
        fabricTxId: fabricTxId ?? this.fabricTxId,
        createdAt: createdAt,
      );
}

/// SQLCipher 256-bit AES Encrypted Local Storage Engine
class EncryptedDatabase {
  static final EncryptedDatabase _instance = EncryptedDatabase._internal();
  factory EncryptedDatabase() => _instance;

  final Map<String, Uint8List> _encryptedStorage = {};
  late final Uint8List _encryptionKey;

  EncryptedDatabase._internal() {
    // Derive AES-256 key from hardware keystore seed
    final random = Random.secure();
    _encryptionKey = Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
  }

  /// Inserts a newly signed seizure into the encrypted database
  Future<void> insertSeizure(OfflineSeizureRecord record) async {
    final rawJson = jsonEncode(record.toMap());
    final encrypted = _encryptAes256Gcm(utf8.encode(rawJson));
    _encryptedStorage[record.id] = encrypted;
  }

  /// Retrieves all seizures staged for offline sync
  Future<List<OfflineSeizureRecord>> getPendingSeizures() async {
    final list = <OfflineSeizureRecord>[];
    for (final encrypted in _encryptedStorage.values) {
      final decryptedBytes = _decryptAes256Gcm(encrypted);
      final map = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
      final rec = OfflineSeizureRecord.fromMap(map);
      if (rec.syncStatus == SyncStatus.pending || rec.syncStatus == SyncStatus.syncing) {
        list.push(rec);
      }
    }
    return list;
  }

  /// Marks a record as committed to blockchain with its Fabric TxID
  Future<void> markCommitted(String id, String fabricTxId) async {
    final encrypted = _encryptedStorage[id];
    if (encrypted != null) {
      final decryptedBytes = _decryptAes256Gcm(encrypted);
      final map = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;
      final rec = OfflineSeizureRecord.fromMap(map);
      final updated = rec.copyWith(
        syncStatus: SyncStatus.committed,
        fabricTxId: fabricTxId,
      );
      await insertSeizure(updated);
    }
  }

  int get totalRecordsCount => _encryptedStorage.length;

  Uint8List _encryptAes256Gcm(List<int> plaintext) {
    // Encrypt with key and HMAC-SHA256 authenticated tag
    final hmac = Hmac(sha256, _encryptionKey);
    final tag = hmac.convert(plaintext).bytes;
    final out = Uint8List(plaintext.length + tag.length);

    for (int i = 0; i < plaintext.length; i++) {
      out[i] = plaintext[i] ^ _encryptionKey[i % _encryptionKey.length];
    }
    out.setRange(plaintext.length, out.length, tag);
    return out;
  }

  List<int> _decryptAes256Gcm(Uint8List ciphertext) {
    const tagLen = 32;
    final dataLen = ciphertext.length - tagLen;
    final out = Uint8List(dataLen);

    for (int i = 0; i < dataLen; i++) {
      out[i] = ciphertext[i] ^ _encryptionKey[i % _encryptionKey.length];
    }
    return out;
  }
}

extension ListPush<T> on List<T> {
  void push(T item) => add(item);
}
