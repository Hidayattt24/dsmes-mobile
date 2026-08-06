enum ChatSender { user, assistant }

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final List<String>? suggestions;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestions,
  });

  bool get isUser => sender == ChatSender.user;
  bool get isAssistant => sender == ChatSender.assistant;
}
