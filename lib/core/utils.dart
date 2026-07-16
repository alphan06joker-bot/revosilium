import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';

/// Utilitaires REVOSILIUM v3
class RevUtils {
  RevUtils._();

  static Future<String> getLocalIP() async {
    try {
      for (final iface in await NetworkInterface.list()) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  static void hapticLight() => HapticFeedback.lightImpact();
  static void hapticMedium() => HapticFeedback.mediumImpact();
  static void hapticHeavy() => HapticFeedback.heavyImpact();

  static int randomDelay(int baseMs, int varianceMs) {
    return baseMs + Random().nextInt(varianceMs);
  }

  static String generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999).toString().padLeft(4, '0')}';

  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  static Future<int> fileSize(String path) async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }
}
