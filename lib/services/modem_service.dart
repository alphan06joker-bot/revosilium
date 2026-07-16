import 'dart:io';
import 'dart:async';
import '../core/constants.dart';

/// Statut du modem GSM
enum ModemStatus { unknown, available, busy, error, notSupported }

/// Service d'interface modem GSM
/// Détection automatique + envoi/réception SMS
class ModemService {
  static final ModemService _instance = ModemService._();
  factory ModemService() => _instance;
  ModemService._();

  String? _modemPath;
  ModemStatus _status = ModemStatus.unknown;
  final _statusCtrl = StreamController<ModemStatus>.broadcast();

  Stream<ModemStatus> get statusStream => _statusCtrl.stream;
  ModemStatus get status => _status;
  String? get path => _modemPath;
  bool get isAvailable => _status == ModemStatus.available;

  /// Initialise le modem — détection automatique
  Future<void> init() async {
    _status = ModemStatus.busy;
    _statusCtrl.add(_status);

    // 1. Essaie les chemins Linux natifs
    for (final path in RevConstants.modemPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          _modemPath = path;
          _status = ModemStatus.available;
          _statusCtrl.add(_status);
          return;
        }
      } catch (_) {}
    }

    // 2. Fallback : Termux API
    if (Platform.isAndroid) {
      try {
        final result = await Process.run('which', ['termux-sms-send']);
        if (result.exitCode == 0) {
          _modemPath = 'termux:api';
          _status = ModemStatus.available;
          _statusCtrl.add(_status);
          return;
        }
      } catch (_) {}
    }

    // 3. Pas de modem trouvé → mode simulation
    _modemPath = 'simulation';
    _status = ModemStatus.notSupported;
    _statusCtrl.add(_status);
  }

  /// Envoie un SMS
  Future<bool> sendSMS(String number, String message) async {
    if (_status != ModemStatus.available && _status != ModemStatus.notSupported) {
      return false;
    }

    try {
      _status = ModemStatus.busy;
      _statusCtrl.add(_status);

      if (_modemPath == 'termux:api') {
        await Process.run('termux-sms-send', ['-n', number, message]);
      } else if (_modemPath == 'simulation') {
        // Mode simulation — log uniquement
        await Future.delayed(const Duration(milliseconds: 300));
      } else if (_modemPath != null) {
        // Mode Linux natif (AT commands)
        final modem = File(_modemPath!);
        await modem.writeAsString('AT+CMGS="$number"\r', mode: FileMode.append);
        await Future.delayed(const Duration(milliseconds: 500));
        await modem.writeAsString('$message\x1A', mode: FileMode.append);
      }

      _status = ModemStatus.available;
      _statusCtrl.add(_status);
      return true;
    } catch (e) {
      _status = ModemStatus.error;
      _statusCtrl.add(_status);
      return false;
    }
  }

  /// Lit les SMS entrants
  Future<List<String>> readSMS() async {
    if (_status != ModemStatus.available) return [];

    try {
      if (_modemPath == 'termux:api') {
        final result = await Process.run('termux-sms-list', ['-l', '10', '--type', 'inbox']);
        return result.stdout.toString().split('\n').where((s) => s.isNotEmpty).toList();
      }
      if (_modemPath == 'simulation') return [];
      if (_modemPath != null) {
        final modem = File(_modemPath!);
        await modem.writeAsString('AT+CMGL="ALL"\r', mode: FileMode.append);
        await Future.delayed(const Duration(milliseconds: 500));
        final content = await modem.readAsString();
        return content.split('\n').where((s) => s.isNotEmpty).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Marque un SMS comme lu
  Future<void> markRead(String id) async {
    try {
      if (_modemPath == 'termux:api') {
        await Process.run('termux-sms-mark-read', [id]);
      }
    } catch (_) {}
  }

  /// Efface les logs système (logcat, dmesg)
  Future<void> wipeLogs() async {
    try {
      await Process.run('logcat', ['-c']);
      await Process.run('dmesg', ['-c']);
    } catch (_) {}
  }

  /// Effacement sécurisé (shred)
  Future<void> shredFile(String path) async {
    try {
      await Process.run('shred', ['-fuz', path]);
      await Process.run('rm', ['-f', path]);
    } catch (_) {
      // Fallback
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  void dispose() {
    _statusCtrl.close();
  }
}
