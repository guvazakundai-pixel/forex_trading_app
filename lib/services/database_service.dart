import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/signal_model.dart';

class DatabaseService {
  static Database? _database;
  static const String DB_NAME = 'forex_app.db';
  static const String TABLE_CHAT = 'chat_messages';
  static const String TABLE_TRADES = 'trade_history';
  static const String TABLE_SETTINGS = 'user_settings';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Chat messages table
    await db.execute('''
      CREATE TABLE $TABLE_CHAT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_signal INTEGER NOT NULL DEFAULT 0,
        signal_type TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Trade history table
    await db.execute('''
      CREATE TABLE $TABLE_TRADES (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pair TEXT NOT NULL,
        type TEXT NOT NULL,
        entry_price REAL NOT NULL,
        stop_loss REAL NOT NULL,
        take_profit REAL NOT NULL,
        confidence REAL NOT NULL,
        risk_level TEXT NOT NULL,
        result TEXT,
        profit_loss REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // User settings table
    await db.execute('''
      CREATE TABLE $TABLE_SETTINGS (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // Chat operations
  static Future<int> saveChatMessage(String user, String message, {bool isSignal = false, String? signalType}) async {
    final db = await database;
    return await db.insert(TABLE_CHAT, {
      'user': user,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'is_signal': isSignal ? 1 : 0,
      'signal_type': signalType,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getChatMessages({int limit = 50}) async {
    final db = await database;
    return await db.query(
      TABLE_CHAT,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Trade operations
  static Future<int> saveTrade(TradeSignal trade) async {
    final db = await database;
    return await db.insert(TABLE_TRADES, {
      'pair': trade.pair,
      'type': trade.type,
      'entry_price': trade.entryPrice,
      'stop_loss': trade.stopLoss,
      'take_profit': trade.takeProfit,
      'confidence': trade.confidence,
      'risk_level': trade.riskLevel,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getTrades({int limit = 50}) async {
    final db = await database;
    return await db.query(
      TABLE_TRADES,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Settings operations
  static Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      TABLE_SETTINGS,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      TABLE_SETTINGS,
      where: 'key = ?',
      whereArgs: [key],
    );
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  // Clear all data (for testing)
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete(TABLE_CHAT);
    await db.delete(TABLE_TRADES);
    await db.delete(TABLE_SETTINGS);
  }
}
