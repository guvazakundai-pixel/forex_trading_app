import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  static Future<Map<String, dynamic>> analyzeSentiment(String currency) async {
    // In real app, use OpenAI or similar for sentiment analysis
    // This is a simplified version using news keywords

    final keywords = _getCurrencyKeywords(currency);
    final bullishKeywords = ['surge', 'gain', 'rise', 'bullish', 'growth', 'strong', 'rally'];
    final bearishKeywords = ['fall', 'drop', 'bearish', 'weak', 'decline', 'crisis', 'recession'];

    // Simulated sentiment based on currency
    final random = DateTime.now().millisecond;
    final bullish = 40 + (random % 40); // 40-80%
    final bearish = 100 - bullish;

    return {
      'bullish': bullish,
      'bearish': bearish,
      'neutral': 20,
      'summary': _generateSummary(currency, bullish),
      'sources': _getSentimentSources(currency),
    };
  }

  static List<String> _getCurrencyKeywords(String currency) {
    final keywords = <String>[];
    switch (currency) {
      case 'USD':
        keywords.addAll(['Federal Reserve', 'Fed', 'interest rate', 'inflation', 'NFP']);
      case 'EUR':
        keywords.addAll(['ECB', 'Eurozone', 'inflation', 'Draghi', 'Lagarde']);
      case 'GBP':
        keywords.addAll(['Bank of England', 'BoE', 'Brexit', 'UK economy']);
      default:
        keywords.addAll([currency, 'central bank', 'economy']);
    }
    return keywords;
  }

  static String _generateSummary(String currency, int bullish) {
    if (bullish > 70) {
      return 'Market sentiment is strongly bullish on $currency. Most indicators suggest upward momentum.';
    } else if (bullish > 55) {
      return 'Market sentiment is moderately bullish on $currency. Some positive signals detected.';
    } else if (bullish > 45) {
      return 'Market sentiment is neutral on $currency. Mixed signals from market.';
    } else if (bullish > 30) {
      return 'Market sentiment is moderately bearish on $currency. Some downside risks.';
    } else {
      return 'Market sentiment is strongly bearish on $currency. Most indicators suggest downward pressure.';
    }
  }

  static List<Map<String, String>> _getSentimentSources(String currency) {
    return [
      {'source': 'Reuters', 'sentiment': 'bullish', 'summary': '$currency showing strength against major pairs'},
      {'source': 'Bloomberg', 'sentiment': 'neutral', 'summary': 'Mixed economic data affecting $currency'},
      {'source': 'Financial Times', 'sentiment': 'bearish', 'summary': '$currency under pressure from policy changes'},
    ];
  }

  static String getSentimentText(int bullishPercent) {
    if (bullishPercent > 70) return 'Strongly Bullish 🚀';
    if (bullishPercent > 55) return 'Bullish 📈';
    if (bullishPercent > 45) return 'Neutral 😐';
    if (bullishPercent > 30) return 'Bearish 📉';
    return 'Strongly Bearish 🐻';
  }
}
