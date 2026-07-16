/// REVOSILIUM v3 — Constantes globales
class RevConstants {
  RevConstants._();

  // App
  static const String appName = 'REVOSILIUM';
  static const String version = '3.0.0';
  static const int defaultPort = 9000;
  static const int maxReconnectAttempts = 10;
  static const int keepAliveInterval = 10; // secondes

  // BlackBox
  static const String phantomPrefix = 'PHANTOM';
  static const String ghostPrefix = 'GHOST';
  static const int smsChunkSize = 140;
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const String defaultPassword = 'revosilium2024';
  static const int smsSendDelay = 500; // ms entre SMS

  // Chemins modem Linux
  static const List<String> modemPaths = [
    '/dev/smd0',
    '/dev/ttyUSB0',
    '/dev/ttyACM0',
    '/dev/rfcomm0',
  ];

  // Encryption
  static const String salt = 'salt_salt_salt';
  static const int pbkdf2Iterations = 100000;
  static const int keyLength = 32;
}
