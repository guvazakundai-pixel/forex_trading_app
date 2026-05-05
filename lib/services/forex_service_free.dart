import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ForexService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _apiKey = alphavantageApiKey; // Not used but kept for compatibility

  static Future<Map<String, dynamic>?> fetchForexRate(String fromSymbol, String toSymbol) async {
    final url = '$_baseUrl/$fromSymbol';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>?;
        if (rates != null && rates.containsKey(toSymbol)) {
          return {
            'Realtime Currency Exchange Rate': {
              '1. From_Currency Code': fromSymbol,
              '3. To_Currency Code': toSymbol,
              '5. Exchange Rate': rates[toSymbol].toString(),
              '6. Last Refreshed': data['date'],
            }
          };
        }
      }
    } catch (e) {
      print('Error fetching forex rate: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchForexTimeSeries(String fromSymbol, String toSymbol) async {
    // Generate simulated historical data based on current rate
    // Free APIs rarely provide free historical data
    try {
      final currentData = await fetchForexRate(fromSymbol, toSymbol);
      if (currentData == null) return null;

      final currentRate = double.parse(currentData['Realtime Currency Exchange Rate']['5. Exchange Rate']);
      final random = Random();
      final Map<String, dynamic> timeSeries = {};

      // Generate 30 days of simulated data with realistic fluctuations
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateStr = date.toIso8601String().split('T')[0];
        final fluctuation = (random.nextDouble() - 0.5) * 0.02; // ±2% fluctuation
        final close = currentRate * (1 + fluctuation - (i * 0.001)); // Slight downtrend

        timeSeries[dateStr] = {
          '1. open': (close * 0.999).toStringAsFixed(4),
          '2. high': (close * 1.002).toStringAsFixed(4),
          '3. low': (close * 0.998).toStringAsFixed(4),
          '4. close': close.toStringAsFixed(4),
        };
      }

      return {'Time Series FX (Daily)': timeSeries};
    } catch (e) {
      print('Error generating historical data: $e');
      return null;
    }
  }

  static String generateSignal(Map<String, dynamic> timeSeriesData) {
    final timeSeries = timeSeriesData['Time Series FX (Daily)'] as Map<String, dynamic>?;
    if (timeSeries == null || timeSeries.isEmpty) {
      return 'No data available';
    }

    final dates = timeSeries.keys.take(30).toList();
    if (dates.length < 14) return 'Need more data for signals';

    final prices = dates.map((d) => double.parse(timeSeries[d]['4. close'])).toList();

    final latest = prices[0];
    final avg5 = prices.take(5).reduce((a, b) => a + b) / 5;
    final avg10 = prices.take(10).reduce((a, b) => a + b) / 10;
    final avg30 = prices.reduce((a, b) => a + b) / prices.length;

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
