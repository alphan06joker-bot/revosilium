import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Extensions Dart utiles pour REVOSILIUM v3
extension StringX on String {
  String get sha256 => sha256.convert(utf8.encode(this)).toString();
  String get md5 => md5.convert(utf8.encode(this)).toString();
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String truncate(int maxLen) =>
      length > maxLen ? '${substring(0, maxLen)}...' : this;
  bool get isPhoneNumber => RegExp(r'^\+?[\d\s\-()]{7,15}$').hasMatch(this);
}

extension IntX on int {
  String get formatBytes {
    if (this < 1024) return '$this o';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} Ko';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} Go';
  }

  String get pad2 => toString().padLeft(2, '0');

  Duration get seconds => Duration(seconds: this);
  Duration get ms => Duration(milliseconds: this);
}

extension DateTimeX on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'à l\'instant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}j';
    return '${day.pad2}/${month.pad2}';
  }

  String get formatted =>
      '${day.pad2}/${month.pad2}/${year} ${hour.pad2}:${minute.pad2}';
}

extension RandomX on Random {
  String nextId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${nextInt(9999).toString().padLeft(4, '0')}';
}
