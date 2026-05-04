import 'dart:convert';
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
    final url = '$_baseUrl?function=FX_DAILY&from_symbol=$fromSymbol&to_symbol=$toSymbol&apikey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching forex time series: $e');
    }
    return null;
  }

  static String generateSignal(Map<String, dynamic> timeSeriesData) {
    final timeSeries = timeSeriesData['Time Series FX (Daily)'] as Map<String, dynamic>?;
    if (timeSeries == null || timeSeries.isEmpty) return 'Insufficient data';

    final dates = timeSeries.keys.take(5).toList();
    final prices = dates.map((d) => double.parse(timeSeries[d]['4. close'])).toList();

    final latest = prices[0];
    final avg3 = prices.take(3).reduce((a, b) => a + b) / 3;

    if (latest > avg3) return 'BUY Signal - Price above 3-day average';
    if (latest < avg3) return 'SELL Signal - Price below 3-day average';
    return 'HOLD - Price stable';
  }
}
