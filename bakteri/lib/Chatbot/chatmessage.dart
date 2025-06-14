class ChatMessage {
  final int id;
  final int chatId;
  final String message;
  final bool isFromUser;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      chatId: map['chat_id'],
      message: map['message'],
      isFromUser: map['is_from_user'] == 1,
      timestamp: map['timestamp'],
    );
  }
}
