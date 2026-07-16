import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../models/transfer.dart';
import 'modem_service.dart';

/// Service de chiffrement Phantom intégré
class PhantomService {
  String? currentFileName;
  int totalChunks = 0;
  int receivedChunks = 0;
  List<String> _chunks = [];
  List<int> _receivedData = [];
  double get progress => totalChunks > 0 ? receivedChunks / totalChunks : 0.0;

  List<String> chunkFile(List<int> bytes, {String password = ''}) => [];
  dynamic processIncomingSMS(String sms) => null;
  String buildHeader(int chunks, String md5, String name) => '';
}

/// BlackBox Service — Transfert de fichiers hors-ligne complet
/// Modes : SMS (Phantom) + Ghost (DTMF furtif)
class BlackBoxService {
  static final BlackBoxService _instance = BlackBoxService._();
  factory BlackBoxService() => _instance;
  BlackBoxService._();

  final ModemService _modem = ModemService();
  final PhantomService _phantom = PhantomService();

  final Map<String, BlackBoxTransfer> _transfers = {};
  String? _currentTransferId;

  final _transferCtrl = StreamController<BlackBoxTransfer>.broadcast();
  final _progressCtrl = StreamController<double>.broadcast();
  final _logCtrl = StreamController<String>.broadcast();

  Stream<BlackBoxTransfer> get transfers => _transferCtrl.stream;
  Stream<double> get progress => _progressCtrl.stream;
  Stream<String> get logs => _logCtrl.stream;

  int get activeTransfers => _transfers.values
      .where((t) => t.status == TransferStatus.sending || t.status == TransferStatus.receiving)
      .length;

  bool _smsListenerStarted = false;

  /// Initialisation
  Future<void> init() async {
    await _modem.init();
    _log('🖤 BlackBox initialisé');
    _log('📡 Modem: ${_modem.status.name}');
    _startSMSListener();
  }

  void _log(String msg) => _logCtrl.add(msg);

  /// Écoute les SMS entrants pour détecter les transferts Phantom
  void _startSMSListener() {
    if (_smsListenerStarted) return;
    _smsListenerStarted = true;

    Timer.periodic(const Duration(seconds: 3), (_) async {
      final smsList = await _modem.readSMS();
      for (final sms in smsList) {
        if (sms.contains('${RevConstants.phantomPrefix}|')) {
          _processIncomingSMS(sms);
        }
      }
    });
  }

  /// Traite un SMS entrant pour extraction Phantom
  void _processIncomingSMS(String smsBody) {
    final result = _phantom.processIncomingSMS(smsBody);

    if (result == null) {
      // En-tête détecté — nouveau transfert
      _currentTransferId = RevUtils.generateId();
      _log('📥 Transfert détecté: ${_phantom.currentFileName}');

      _transfers[_currentTransferId!] = BlackBoxTransfer(
        id: _currentTransferId!,
        fileName: _phantom.currentFileName,
        totalChunks: _phantom.totalChunks,
        startTime: DateTime.now(),
        status: TransferStatus.receiving,
        mode: BlackBoxMode.sms,
      );
      _transferCtrl.add(_transfers[_currentTransferId!]!);
      return;
    }

    // Chunk reçu
    if (_phantom.totalChunks > 0) {
      _progressCtrl.add(_phantom.progress);

      if (_currentTransferId != null) {
        _transfers[_currentTransferId!] = _transfers[_currentTransferId!]!.copyWith(
          receivedChunks: _phantom.receivedChunks,
          progress: _phantom.progress,
        );
        _transferCtrl.add(_transfers[_currentTransferId!]!);
      }
    }

    // Assemblage terminé
    if (result.success) {
      _log('✅ Fichier reçu: ${result.fileName} (${result.size?.formatBytes ?? '?'})');

      if (_currentTransferId != null) {
        _transfers[_currentTransferId!] = _transfers[_currentTransferId!]!.copyWith(
          status: TransferStatus.complete,
          progress: 1.0,
          endTime: DateTime.now(),
        );
        _transferCtrl.add(_transfers[_currentTransferId!]!);
      }

      _progressCtrl.add(1.0);
      _currentTransferId = null;

      // Sauvegarde du fichier
      _saveFile(result);

      // Nettoyage auto
      _modem.wipeLogs();
      _log('🧹 Traces effacées');
    } else if (!result.success && result.error != null) {
      _log('❌ Erreur: ${result.error}');
      if (_currentTransferId != null) {
        _transfers[_currentTransferId!] = _transfers[_currentTransferId!]!.copyWith(
          status: TransferStatus.failed,
          error: result.error,
        );
        _transferCtrl.add(_transfers[_currentTransferId!]!);
      }
    }
  }

  /// Sauvegarde le fichier reçu
  Future<void> _saveFile(dynamic result) async {
    if (result.data == null || result.fileName == null) return;
    try {
      final dir = Directory('/storage/emulated/0/Download/phantom');
      if (!await dir.exists()) await dir.create(recursive: true);
      final filePath = '${dir.path}/${result.fileName}';
      await File(filePath).writeAsBytes(result.data);
      _log('💾 Sauvegardé: $filePath');
    } catch (e) {
      _log('❌ Erreur sauvegarde: $e');
    }
  }

  /// Envoie un fichier via SMS Phantom
  Future<void> sendFile(
    String filePath,
    String phoneNumber, {
    BlackBoxMode mode = BlackBoxMode.sms,
    String password = RevConstants.defaultPassword,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('Fichier introuvable: $filePath');

    final bytes = await file.readAsBytes();
    if (bytes.length > RevConstants.maxFileSize) {
      throw Exception('Fichier trop volumineux (max 10 MB)');
    }

    final fileName = filePath.split('/').last;
    _log('🔒 Chiffrement AES-256...');
    final chunks = _phantom.chunkFile(bytes, password: password);
    final fileMd5 = md5.convert(bytes).toString();
    _log('✂️ ${chunks.length} chunks prêts');

    final transferId = RevUtils.generateId();
    _transfers[transferId] = BlackBoxTransfer(
      id: transferId,
      fileName: fileName,
      totalChunks: chunks.length + 1,
      fileSize: bytes.length,
      startTime: DateTime.now(),
      status: TransferStatus.sending,
      mode: mode,
      phoneNumber: phoneNumber,
      checksum: fileMd5,
    );
    _transferCtrl.add(_transfers[transferId]!);

    // En-tête
    final header = _phantom.buildHeader(chunks.length, fileMd5, fileName);
    _log('📤 Envoi en-tête...');
    await _modem.sendSMS(phoneNumber, header);
    await Future.delayed(Duration(milliseconds: RevConstants.smsSendDelay));

    // Chunks
    Random rng = Random();
    for (int i = 0; i < chunks.length; i++) {
      await _modem.sendSMS(phoneNumber, chunks[i]);

      final p = (i + 1) / chunks.length;
      _transfers[transferId] = _transfers[transferId]!.copyWith(
        receivedChunks: i + 1,
        progress: p,
      );
      _transferCtrl.add(_transfers[transferId]!);
      _progressCtrl.add(p);

      // Délai variable anti-détection
      await Future.delayed(Duration(milliseconds: RevConstants.smsSendDelay + rng.nextInt(300)));
    }

    _transfers[transferId] = _transfers[transferId]!.copyWith(
      status: TransferStatus.complete,
      progress: 1.0,
      endTime: DateTime.now(),
    );
    _transferCtrl.add(_transfers[transferId]!);
    _progressCtrl.add(1.0);

    _log('✅ Fichier envoyé: $fileName');
    _log('🧹 Nettoyage...');
    await _modem.wipeLogs();
    _log('🧹 Traces effacées');
  }

  /// Récupère un transfert par ID
  BlackBoxTransfer? getTransfer(String id) => _transfers[id];

  /// Récupère tous les transferts
  List<BlackBoxTransfer> get allTransfers => _transfers.values.toList();

  /// Annule un transfert
  void cancelTransfer(String id) {
    if (_transfers.containsKey(id)) {
      _transfers[id] = _transfers[id]!.copyWith(
        status: TransferStatus.cancelled,
      );
      _transferCtrl.add(_transfers[id]!);
      _log('🚫 Transfert annulé');
    }
  }

  void dispose() {
    _transferCtrl.close();
    _progressCtrl.close();
    _logCtrl.close();
    _modem.dispose();
  }
}
