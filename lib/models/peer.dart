/// Modèle Pair pour REVOSILIUM v3
class Peer {
  final String id;
  final String name;
  final String phoneNumber;
  final String? ipAddress;
  final String? publicKey;
  final DateTime addedAt;
  final bool isFavorite;
  final int messagesCount;
  final DateTime? lastMessage;
  final bool isOnline;
  final String? lastSeen;

  Peer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.ipAddress,
    this.publicKey,
    required this.addedAt,
    this.isFavorite = false,
    this.messagesCount = 0,
    this.lastMessage,
    this.isOnline = false,
    this.lastSeen,
  });

  Peer copyWith({
    String? name,
    String? phoneNumber,
    String? ipAddress,
    String? publicKey,
    bool? isFavorite,
    int? messagesCount,
    DateTime? lastMessage,
    bool? isOnline,
    String? lastSeen,
  }) {
    return Peer(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      ipAddress: ipAddress ?? this.ipAddress,
      publicKey: publicKey ?? this.publicKey,
      addedAt: addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      messagesCount: messagesCount ?? this.messagesCount,
      lastMessage: lastMessage ?? this.lastMessage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'ipAddress': ipAddress,
        'publicKey': publicKey,
        'addedAt': addedAt.toIso8601String(),
        'isFavorite': isFavorite,
        'messagesCount': messagesCount,
        'lastMessage': lastMessage?.toIso8601String(),
      };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        ipAddress: json['ipAddress'],
        publicKey: json['publicKey'],
        addedAt: DateTime.tryParse(json['addedAt'] ?? '') ?? DateTime.now(),
        isFavorite: json['isFavorite'] ?? false,
        messagesCount: json['messagesCount'] ?? 0,
        lastMessage: json['lastMessage'] != null
            ? DateTime.tryParse(json['lastMessage'])
            : null,
      );
}
