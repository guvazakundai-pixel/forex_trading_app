import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'a41e2bb53da84165b014452f7d361a17'; // Get free key from newsapi.org

  static Future<List<dynamic>> fetchForexNews(String currency) async {
    final url = '$_baseUrl/everything?q=$currency forex OR $currency currency&sortBy=publishedAt&language=en&pageSize=10&apiKey=$_apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          return data['articles'] ?? [];
        }
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
    return [];
  }
}
