import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_service.dart';

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

  // Create from database map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      user: map['user'],
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
      isSignal: map['is_signal'] == 1,
      signalType: map['signal_type'],
    );
  }
}

class ChatService {
  static List<ChatMessage> _messages = [];

  static Future<List<ChatMessage>> getMessages() async {
    // Load from database if empty
    if (_messages.isEmpty) {
      final dbMessages = await DatabaseService.getChatMessages();
      _messages = dbMessages.map((map) => ChatMessage.fromMap(map)).toList();
    }
    return List.from(_messages);
  }

  static Future<void> addMessage(String user, String message) async {
    final chatMessage = ChatMessage(
      user: user,
      message: message,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, chatMessage);
    // Save to database
    await DatabaseService.saveChatMessage(user, message);
  }

  static Future<void> addSignalMessage(String signal, String type) async {
    final chatMessage = ChatMessage(
      user: 'SignalBot',
      message: '🚨 $signal',
      timestamp: DateTime.now(),
      isSignal: true,
      signalType: type,
    );
    _messages.insert(0, chatMessage);
    // Save to database
    await DatabaseService.saveChatMessage(
      'SignalBot',
      '🚨 $signal',
      isSignal: true,
      signalType: type,
    );
  }

  static Future<void> loadInitialMessages() async {
    // Only add default messages if database is empty
    final existing = await DatabaseService.getChatMessages();
    if (existing.isEmpty) {
      final defaultMessages = [
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
        // ... other default messages
      ];

      for (var msg in defaultMessages) {
        await DatabaseService.saveChatMessage(
          msg.user,
          msg.message,
          isSignal: msg.isSignal,
          signalType: msg.signalType,
        );
      }
      _messages = defaultMessages;
    }
  }
}
