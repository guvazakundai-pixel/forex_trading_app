import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ForexService {
  static const String _baseUrl = 'https://www.alphavantage.co/query';
  static const String _apiKey = alphavantageApiKey;

  static Future<Map<String, dynamic>?> fetchForexRate(String fromSymbol, String toSymbol) async {
    final url = '$_baseUrl?function=CURRENCY_EXCHANGE_RATE&from_currency=$fromSymbol&to_currency=$toSymbol&apikey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching forex rate: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchForexTimeSeries(String fromSymbol, String toSymbol) async {
    // Add delay to avoid API rate limits
    await Future.delayed(const Duration(seconds: 12));
    
    final url = '$_baseUrl?function=FX_DAILY&from_symbol=$fromSymbol&to_symbol=$toSymbol&apikey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check for API limit messages
        if (data.containsKey('Note')) {
          print('API Limit: ${data['Note']}');
          return {'Error': 'API_LIMIT', 'Message': data['Note']};
        }
        return data;
      }
    } catch (e) {
      print('Error fetching forex time series: $e');
    }
    return null;
  }

  static String generateSignal(Map<String, dynamic> timeSeriesData) {
    // Check for errors first
    if (timeSeriesData.containsKey('Error')) {
      return 'API Limit - Try again in 1 minute';
    }
    
    final timeSeries = timeSeriesData['Time Series FX (Daily)'] as Map<String, dynamic>?;
    if (timeSeries == null || timeSeries.isEmpty) {
      return 'No data - Try EUR/USD';
    }

    final dates = timeSeries.keys.take(30).toList();
    if (dates.length < 14) return 'Need more data for signals';

    final prices = dates.map((d) => double.parse(timeSeries[d]['4. close'])).toList();

    final latest = prices[0];
    final avg5 = prices.take(5).reduce((a, b) => a + b) / 5;
    final avg10 = prices.take(10).reduce((a, b) => a + b) / 10;

    // RSI calculation (14 periods)
    double calculateRSI(List<double> prices) {
      if (prices.length < 14) return 50;
      double gain = 0, loss = 0;
      for (int i = 1; i < 14; i++) {
        final diff = prices[i - 1] - prices[i];
        if (diff > 0) gain += diff;
        else loss -= diff;
      }
      if (loss == 0) return 100;
      final rs = gain / loss;
      return 100 - (100 / (1 + rs));
    }

    final rsi = calculateRSI(prices);
    final rsiSignal = rsi < 30 ? 'OVERSOLD' : (rsi > 70 ? 'OVERBOUGHT' : 'NEUTRAL');

    // Determine signal
    if (latest > avg5 && latest > avg10 && rsi < 70) {
      return 'STRONG BUY - RSI: ${rsi.toStringAsFixed(1)} ($rsiSignal)';
    }
    if (latest > avg10 && rsi < 30) {
      return 'BUY - Potential reversal, RSI: ${rsi.toStringAsFixed(1)} ($rsiSignal)';
    }
    if (latest < avg5 && latest < avg10 && rsi > 70) {
      return 'STRONG SELL - RSI: ${rsi.toStringAsFixed(1)} ($rsiSignal)';
    }
    if (latest < avg10 && rsi > 70) {
      return 'SELL - Potential reversal, RSI: ${rsi.toStringAsFixed(1)} ($rsiSignal)';
    }
    return 'HOLD - RSI: ${rsi.toStringAsFixed(1)} ($rsiSignal)';
  }

  static List<Map<String, dynamic>> getChartData(Map<String, dynamic> timeSeriesData) {
    final timeSeries = timeSeriesData['Time Series FX (Daily)'] as Map<String, dynamic>?;
    if (timeSeries == null) return [];

    final dates = timeSeries.keys.take(30).toList();
    return dates.map((date) {
      final data = timeSeries[date];
      return {
        'date': date,
        'open': double.parse(data['1. open']),
        'high': double.parse(data['2. high']),
        'low': double.parse(data['3. low']),
        'close': double.parse(data['4. close']),
      };
    }).toList();
  }
}
