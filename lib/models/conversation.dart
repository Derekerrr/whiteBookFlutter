// enum PeerType { USER, GROUP }
//
// PeerType peerTypeFromString(String type) {
//   return PeerType.values.firstWhere((e) => e.toString().split('.').last == type);
// }
//
// String peerTypeToString(PeerType type) {
//   return type.toString().split('.').last;
// }
//
// class Conversation {
//   final int id;
//   final int? userId;
//   final int peerId;
//   final PeerType? peerType;
//   final int? lastMessageId;
//   final int unreadCount;
//   final DateTime? updatedAt;
//
//   Conversation({
//     required this.id,
//     this.userId,
//     required this.peerId,
//     this.peerType,
//     this.lastMessageId,
//     required this.unreadCount,
//     this.updatedAt,
//   });
//
//   factory Conversation.fromJson(Map<String, dynamic> json) {
//     return Conversation(
//       id: json['id'],
//       userId: json['userId'],
//       peerId: json['peerId'],
//       peerType: peerTypeFromString(json['peerType']),
//       lastMessageId: json['lastMessageId'],
//       unreadCount: json['unreadCount'] ?? 0,
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'peerId': peerId,
//       'peerType': peerTypeToString(peerType!),
//       'lastMessageId': lastMessageId,
//       'unreadCount': unreadCount,
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }
// }
