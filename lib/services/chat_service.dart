class ChatMessage {
  final String user;
  final String message;
  final DateTime timestamp;
  final bool isSignal;
  final String? signalType; // BUY, SELL, or null

  ChatMessage({
    required this.user,
    required this.message,
    required this.timestamp,
    this.isSignal = false,
    this.signalType,
  });
}

class ChatService {
  static final List<ChatMessage> _messages = [
    ChatMessage(
      user: 'SignalBot',
      message: '🚨 STRONG BUY signal detected for EUR/USD - RSI: 42 (OVERSOLD), Price above 5-day MA',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isSignal: true,
      signalType: 'BUY',
    ),
    ChatMessage(
      user: 'TraderPro',
      message: 'EUR/USD looking bullish today! RSI at 45, good entry point. Target 1.0900?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
    ),
    ChatMessage(
      user: 'ZimTrader',
      message: 'Just got STRONG BUY signal on GBP/USD. Target 1.2750?',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    ChatMessage(
      user: 'SignalBot',
      message: '🚨 SELL signal detected for USD/JPY - RSI: 72 (OVERBOUGHT)',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isSignal: true,
      signalType: 'SELL',
    ),
    ChatMessage(
      user: 'ForexGuru',
      message: 'News coming out for USD pairs. Be careful with entries until after 2:00 PM.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatMessage(
      user: 'NewTrader',
      message: 'What does RSI mean? Still learning, this app helps a lot!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    ChatMessage(
      user: 'ProTrader',
      message: 'RSI = Relative Strength Index. Below 30 = oversold (BUY), above 70 = overbought (SELL). Good luck!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  static List<ChatMessage> getMessages() => List.from(_messages); // Return copy

  static void addMessage(String user, String message) {
    _messages.insert(0, ChatMessage(
      user: user,
      message: message,
      timestamp: DateTime.now(),
    ));
  }

  static void addSignalMessage(String signal, String type) {
    _messages.insert(0, ChatMessage(
      user: 'SignalBot',
      message: '🚨 $signal',
      timestamp: DateTime.now(),
      isSignal: true,
      signalType: type,
    ));
  }
}
