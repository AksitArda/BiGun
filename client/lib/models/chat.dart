class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime time;
  final bool isAudio;
  final String? audioUrl;
  final Duration? audioDuration;
  final List<double>? waveformData;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.time,
    this.isAudio = false,
    this.audioUrl,
    this.audioDuration,
    this.waveformData,
  });
}

class ChatRoom {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime lastMessageTime;
  final String? lastMessage;
  final bool hasUnreadMessages;

  ChatRoom({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessageTime,
    this.lastMessage,
    this.hasUnreadMessages = false,
  });
}

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final DateTime time;
  final FriendRequestStatus status;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.time,
    this.status = FriendRequestStatus.pending,
  });
}

enum FriendRequestStatus {
  pending,
  accepted,
  rejected
}
