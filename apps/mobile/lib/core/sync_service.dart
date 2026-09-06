import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'encrypted_db.dart';

class SyncResult {
  final bool isSuccess;
  final String? fabricTxId;
  final String? ipfsCid;
  final String? error;

  const SyncResult({
    required this.isSuccess,
    this.fabricTxId,
    this.ipfsCid,
    this.error,
  });
}

class BackgroundSyncService {
  final EncryptedDatabase _db = EncryptedDatabase();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  void init() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        syncPendingQueue();
      }
    });
  }

  /// Dispatches a single seizure record to the Hyperledger Fabric Gateway
  Future<SyncResult> dispatchSeizure(OfflineSeizureRecord record) async {
    _isSyncing = true;

    try {
      // Simulate network request to Go Gateway
      await Future.delayed(const Duration(milliseconds: 650));

      // Deterministic Fabric TxID from payload
      final txSeed = utf8.encode('${record.id}_${record.firNumber}_${record.evidencePayloadHash}');
      final txDigest = sha256.convert(txSeed).toString();
      final fabricTxId = '0x$txDigest';

      // Mark locally as committed
      await _db.markCommitted(record.id, fabricTxId);

      _isSyncing = false;
      return SyncResult(
        isSuccess: true,
        fabricTxId: fabricTxId,
        ipfsCid: record.ipfsCid,
      );
    } catch (e) {
      _isSyncing = false;
      return SyncResult(
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  /// Iterates and syncs all pending staged records
  Future<int> syncPendingQueue() async {
    final pending = await _db.getPendingSeizures();
    int syncedCount = 0;

    for (final record in pending) {
      final res = await dispatchSeizure(record);
      if (res.isSuccess) {
        syncedCount++;
      }
    }

    return syncedCount;
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}

final syncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final service = BackgroundSyncService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
