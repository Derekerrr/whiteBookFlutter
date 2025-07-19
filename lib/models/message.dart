class Message {
  final String? text;
  final bool isSender;
  final DateTime timestamp;
  final String? imageUrl;

  Message({
    this.text,
    required this.isSender,
    required this.timestamp,
    this.imageUrl,
  });
}
