import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlertService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final Map<String, double> _priceAlets = {};
  static final Map<String, String> _signalAlerts = {};

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOs: iosSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> setPriceAlert(String pair, double targetPrice, bool isAbove) async {
    final key = '${pair}_${isAbove ? "above" : "below"}';
    _priceAlets[key] = targetPrice;
    await _schedulePriceCheck(pair, targetPrice, isAbove);
  }

  static Future<void> _schedulePriceCheck(String pair, double targetPrice, bool isAbove) async {
    // In real app, use background service or push notifications
    // This is a simplified version
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      // Check price logic here
      print('Checking price for $pair: target $targetPrice (${isAbove ? "above" : "below"})');
    });
  }

  static Future<void> showSignalAlert(String pair, String type, double entry) async {
    const androidDetails = AndroidNotificationDetails(
      'signals_channel',
      'Trading Signals',
      channelDescription: 'Notifications for new trading signals',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOs: iosDetails);

    await _notifications.show(
      0,
      '🚨 New $type Signal',
      '$pair - Entry: ${entry.toStringAsFixed(4)}',
      details,
      payload: '$pair|$type|$entry',
    );
  }

  static Future<void> showPriceAlert(String pair, double currentPrice) async {
    const androidDetails = AndroidNotificationDetails(
      'price_channel',
      'Price Alerts',
      channelDescription: 'Notifications for price targets',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOs: iosDetails);

    await _notifications.show(
      1,
      '💰 Price Alert',
      '$pair reached ${currentPrice.toStringAsFixed(4)}',
      details,
      payload: 'price|$pair|$currentPrice',
    );
  }

  static Future<void> cancelAlert(String pair) async {
    _priceAlets.removeWhere((key, value) => key.startsWith(pair));
  }
}
