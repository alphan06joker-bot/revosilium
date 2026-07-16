import 'dart:convert';

enum MessageType { text, file, voice, system }

enum MessageStatus { sending, sent, delivered, seen, failed }

class ChatMessage {
  final String id;
  final String? text;
  final MessageType type;
  final bool isMe;
  final DateTime time;
  final MessageStatus status;
  final String? fileName;
  final int? fileSize;
  final String? filePath;
  final String? voicePath;
  final int? voiceDuration;
  final bool ephemeral;
  final Map<String, int>? reactions;

  ChatMessage({
    required this.id,
    this.text,
    this.type = MessageType.text,
    required this.isMe,
    DateTime? time,
    this.status = MessageStatus.sent,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.voicePath,
    this.voiceDuration,
    this.ephemeral = false,
    this.reactions,
  }) : time = time ?? DateTime.now();

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    Map<String, int>? reactions,
    bool? ephemeral,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      type: type,
      isMe: isMe,
      time: time,
      status: status ?? this.status,
      fileName: fileName,
      fileSize: fileSize,
      filePath: filePath,
      voicePath: voicePath,
      voiceDuration: voiceDuration,
      ephemeral: ephemeral ?? this.ephemeral,
      reactions: reactions ?? this.reactions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type.index,
    'isMe': isMe,
    'time': time.toIso8601String(),
    'status': status.index,
    'fileName': fileName,
    'fileSize': fileSize,
    'filePath': filePath,
    'voicePath': voicePath,
    'voiceDuration': voiceDuration,
    'ephemeral': ephemeral,
    'reactions': reactions != null ? jsonEncode(reactions) : null,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    Map<String, int>? reactions;
    if (json['reactions'] != null) {
      reactions = Map<String, int>.from(jsonDecode(json['reactions']));
    }
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      type: MessageType.values[json['type'] ?? 0],
      isMe: json['isMe'],
      time: DateTime.parse(json['time']),
      status: MessageStatus.values[json['status'] ?? 0],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      filePath: json['filePath'],
      voicePath: json['voicePath'],
      voiceDuration: json['voiceDuration'],
      ephemeral: json['ephemeral'] ?? false,
      reactions: reactions,
    );
  }
}

class PeerInfo {
  final String ip;
  final String? nickname;
  final String? publicKey;
  final DateTime firstSeen;
  DateTime lastSeen;

  PeerInfo({
    required this.ip,
    this.nickname,
    this.publicKey,
    DateTime? firstSeen,
    DateTime? lastSeen,
  })  : firstSeen = firstSeen ?? DateTime.now(),
        lastSeen = lastSeen ?? DateTime.now();
}
