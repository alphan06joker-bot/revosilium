import '../core/constants.dart';

/// Statut de transfert BlackBox
enum TransferStatus { idle, sending, receiving, complete, failed, cancelled }

/// Mode de transfert BlackBox
enum BlackBoxMode { sms, ghost, both }

/// Modèle de transfert BlackBox
class BlackBoxTransfer {
  final String id;
  final String fileName;
  final int totalChunks;
  final int receivedChunks;
  final double progress;
  final TransferStatus status;
  final String? checksum;
  final DateTime startTime;
  final DateTime? endTime;
  final BlackBoxMode mode;
  final String? phoneNumber;
  final int fileSize;
  final String? error;

  BlackBoxTransfer({
    required this.id,
    required this.fileName,
    required this.totalChunks,
    this.receivedChunks = 0,
    this.progress = 0.0,
    this.status = TransferStatus.idle,
    this.checksum,
    required this.startTime,
    this.endTime,
    this.mode = BlackBoxMode.sms,
    this.phoneNumber,
    this.fileSize = 0,
    this.error,
  });

  BlackBoxTransfer copyWith({
    int? receivedChunks,
    double? progress,
    TransferStatus? status,
    DateTime? endTime,
    String? error,
  }) {
    return BlackBoxTransfer(
      id: id,
      fileName: fileName,
      totalChunks: totalChunks,
      receivedChunks: receivedChunks ?? this.receivedChunks,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      checksum: checksum,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      mode: mode,
      phoneNumber: phoneNumber,
      fileSize: fileSize,
      error: error ?? this.error,
    );
  }

  int get estimatedSMSCount =>
      totalChunks + 1; // +1 pour l'en-tête

  Duration get elapsed => DateTime.now().difference(startTime);
}

/// Modèle de configuration utilisateur
class Settings {
  String password;
  bool ghostMode;
  bool autoWipe;
  bool vibration;
  bool notifications;
  int smsDelay;
  String language;

  Settings({
    this.password = RevConstants.defaultPassword,
    this.ghostMode = false,
    this.autoWipe = true,
    this.vibration = true,
    this.notifications = true,
    this.smsDelay = 500,
    this.language = 'fr',
  });

  Map<String, dynamic> toJson() => {
        'password': password,
        'ghostMode': ghostMode,
        'autoWipe': autoWipe,
        'vibration': vibration,
        'notifications': notifications,
        'smsDelay': smsDelay,
        'language': language,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        password: json['password'] ?? RevConstants.defaultPassword,
        ghostMode: json['ghostMode'] ?? false,
        autoWipe: json['autoWipe'] ?? true,
        vibration: json['vibration'] ?? true,
        notifications: json['notifications'] ?? true,
        smsDelay: json['smsDelay'] ?? 500,
        language: json['language'] ?? 'fr',
      );
}
