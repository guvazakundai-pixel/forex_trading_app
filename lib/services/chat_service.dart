class ChatMessage {
  final String user;
  final String message;
  final DateTime timestamp;
  final bool isSignal;

  ChatMessage({
    required this.user,
    required this.message,
    required this.timestamp,
    this.isSignal = false,
  });
}

class ChatService {
  static final List<ChatMessage> _messages = [
    ChatMessage(
      user: 'TraderPro',
      message: 'EUR/USD looking bullish today! RSI at 45, good entry point.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      user: 'ZimTrader',
      message: 'Just got STRONG BUY signal on GBP/USD. Target 1.2750?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatMessage(
      user: 'SignalBot',
      message: '🚨 STRONG BUY signal detected for EUR/USD - RSI: 42 (OVERSOLD), Price above 5-day MA',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      isSignal: true,
    ),
  ];

  static List<ChatMessage> getMessages() => _messages;

  static void addMessage(String user, String message) {
    _messages.insert(0, ChatMessage(
      user: user,
      message: message,
      timestamp: DateTime.now(),
    ));
  }

  static void addSignalMessage(String signal) {
    _messages.insert(0, ChatMessage(
      user: 'SignalBot',
      message: '🚨 $signal',
      timestamp: DateTime.now(),
      isSignal: true,
    ));
  }
}
