@pragma('vm:entry-point')
class SmsMessage {
  final int? id;
  final String sender;
  final String content;
  final String status;
  final DateTime timestamp;
  final bool isRead;

  @pragma('vm:entry-point')
  SmsMessage({
    this.id,
    required this.sender,
    required this.content,
    required this.status,
    required this.timestamp,
    this.isRead = false,
  });

  @pragma('vm:entry-point')
  factory SmsMessage.fromMap(Map<String, dynamic> map) {
    return SmsMessage(
      id: map['id'],
      sender: map['sender'],
      content: map['content'],
      status: map['status'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead ? 1 : 0,
    };
  }
}
