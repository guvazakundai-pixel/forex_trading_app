import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'services/forex_service_free.dart';
import 'services/news_service.dart';
import 'services/chat_service.dart';
import 'services/api_config.dart';
import 'models/signal_model.dart';
import 'screens/about_screen.dart';
import 'screens/learning_screen.dart';

void main() {
  runApp(const ForexApp());
}

class ForexApp extends StatelessWidget {
  const ForexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forex Trading Signals',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ForexHomePage(),
    );
  }
}

class ForexHomePage extends StatefulWidget {
  const ForexHomePage({super.key});

  @override
  State<ForexHomePage> createState() => _ForexHomePageState();
}

class _ForexHomePageState extends State<ForexHomePage> {
  Map<String, dynamic>? _forexData;
  Map<String, dynamic>? _historicalData;
  List<dynamic> _news = [];
  List<ChatMessage> _chatMessages = [];
  List<TradeSignal> _tradeSignals = [];
  bool _isLoading = false;
  String _selectedPair = 'EUR/USD';
  int _selectedIndex = 0;
  TradeSignal? _currentSignal;

  final List<String> _pairs = ['EUR/USD', 'GBP/USD', 'USD/JPY', 'USD/ZWL'];

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _chatMessages = ChatService.getMessages();
    _loadTradeSignals();
  }

  void _loadTradeSignals() {
    // Simulated trade signals
    _tradeSignals = [
      TradeSignal(
        pair: 'EUR/USD',
        type: 'BUY',
        entryPrice: 1.0850,
        stopLoss: 1.0820,
        takeProfit: 1.0900,
        confidence: 85,
        riskLevel: 'Low',
        reason: 'STRONG BUY - RSI: 42 (OVERSOLD), Price above 5-day MA',
      ),
      TradeSignal(
        pair: 'GBP/USD',
        type: 'SELL',
        entryPrice: 1.2750,
        stopLoss: 1.2780,
        takeProfit: 1.2700,
        confidence: 75,
        riskLevel: 'Medium',
        reason: 'SELL - RSI: 72 (OVERBOUGHT), Potential reversal',
      ),
    ];
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    String from = _selectedPair.split('/')[0];
    String to = _selectedPair.split('/')[1];

    try {
      final currentData = await ForexService.fetchForexRate(from, to);
      final historicalData = await ForexService.fetchForexTimeSeries(from, to);
      final news = await NewsService.fetchForexNews(from);

      setState(() {
        _forexData = currentData;
        _historicalData = historicalData;
        _news = news.take(10).toList();
        _isLoading = false;
        
        // Generate trade signal from the data
        if (historicalData != null) {
          final signal = ForexService.generateSignal(historicalData);
          final rate = currentData?['Realtime Currency Exchange Rate']?['5. Exchange Rate'];
          if (rate != null) {
            _currentSignal = TradeSignal.fromSignal(_selectedPair, signal, double.parse(rate));
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching data: $e');
    }
  }

  String _getSignal() {
    if (_historicalData == null) return 'Fetch data to see signal';
    return ForexService.generateSignal(_historicalData!);
  }

  List<FlSpot> _getChartSpots() {
    if (_historicalData == null) return [];
    final chartData = ForexService.getChartData(_historicalData!);
    return chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value['close']);
    }).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forex Trading Signals'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningScreen()),
              );
            },
          ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _fetchData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.newspaper), label: 'News'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Learn'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildNewsTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildLearningTab();
      default:
        return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPairSelector(),
          const SizedBox(height: 16),
          if (_forexData != null) _buildRateCard(),
          const SizedBox(height: 16),
          if (_currentSignal != null) _buildSignalCard(),
          const SizedBox(height: 16),
          if (_historicalData != null) _buildChartCard(),
          const SizedBox(height: 16),
          _buildTradeSignalsList(),
        ],
      ),
    );
  }

  Widget _buildPairSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButton<String>(
          value: _selectedPair,
          isExpanded: true,
          underline: const SizedBox(),
          onChanged: (value) => setState(() => _selectedPair = value!),
          items: _pairs.map((pair) => DropdownMenuItem(
                value: pair,
                child: Text(pair, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )).toList(),
        ),
      ),
    );
  }

  Widget _buildRateCard() {
    final rateData = _forexData!['Realtime Currency Exchange Rate'];
    if (rateData == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${rateData['1. From_Currency Code']}/${rateData['3. To_Currency Code']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rateData['5. Exchange Rate'],
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w300, color: Colors.green),
            ),
            Text(
              'Last Update: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(rateData['6. Last Refreshed']))}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard() {
    if (_currentSignal == null) return const SizedBox();

    final signal = _currentSignal!;
    final color = signal.type == 'BUY' ? Colors.green : Colors.red;
    final icon = signal.type == 'BUY' ? Icons.trending_up : Icons.trending_down;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Text('${signal.type} Signal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'Entry: ${signal.entryPrice.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Stop Loss', style: TextStyle(fontSize: 12, color: Colors.red)),
                          Text(signal.stopLoss.toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Take Profit', style: TextStyle(fontSize: 12, color: Colors.green)),
                          Text(signal.takeProfit.toStringAsFixed(4), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Confidence', style: TextStyle(fontSize: 12)),
                          Text('${signal.confidence.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSignalExplanation(signal.reason),
            const SizedBox(height: 12),
            _buildTradeAdvantages(signal.type),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalExplanation(String signal) {
    final isBuy = signal.contains('BUY');
    final color = isBuy ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What this means:', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(signal, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          if (isBuy) ...[
            const Text('• Price is trending upward', style: TextStyle(fontSize: 12)),
            const Text('• Good time to enter LONG position', style: TextStyle(fontSize: 12)),
            const Text('• Set stop-loss to protect against reversals', style: TextStyle(fontSize: 12)),
          ] else ...[
            const Text('• Price is trending downward', style: TextStyle(fontSize: 12)),
            const Text('• Consider EXIT or SHORT position', style: TextStyle(fontSize: 12)),
            const Text('• Take profits to avoid losses', style: TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeAdvantages(String type) {
    final isBuy = type == 'BUY';

    return ExpansionTile(
      title: Text(
        isBuy ? 'Advantages of this Trade' : 'Risks of this Trade',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBuy) ...[
                const Text('✅ Advantages:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('• Potential profit from upward movement', style: TextStyle(fontSize: 12)),
                const Text('• RSI supports entry decision', style: TextStyle(fontSize: 12)),
                const Text('• Technical indicators align', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text('⚠️ Risks:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text('• Market can reverse unexpectedly', style: TextStyle(fontSize: 12)),
                const Text('• News events can impact price', style: TextStyle(fontSize: 12)),
              ] else ...[
                const Text('✅ Advantages of Exiting:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const Text('• Protect profits from decline', style: TextStyle(fontSize: 12)),
                const Text('• Avoid further losses', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text('⚠️ Risks of Holding:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const Text('• May lose accumulated profits', style: TextStyle(fontSize: 12)),
                const Text('• Market could drop further', style: TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    final spots = _getChartSpots();
    if (spots.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('30-Day Price Chart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeSignalsList() {
    if (_tradeSignals.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 All Trade Signals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ... _tradeSignals.map((signal) => _buildSignalTile(signal)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalTile(TradeSignal signal) {
    final color = signal.type == 'BUY' ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(signal.pair, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  signal.type,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSignalDetail('Entry', signal.entryPrice.toStringAsFixed(4)),
              _buildSignalDetail('SL', signal.stopLoss.toStringAsFixed(4)),
              _buildSignalDetail('TP', signal.takeProfit.toStringAsFixed(4)),
              _buildSignalDetail('Confidence', '${signal.confidence.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ],
    );
  }

  Widget _buildNewsTab() {
    if (_news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.newspaper, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No news loaded yet', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Load News'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _news.length,
      itemBuilder: (context, index) {
        final article = _news[index];
        return _buildNewsCard(article);
      },
    );
  }

  Widget _buildNewsCard(dynamic article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article['urlToImage'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const SizedBox(height: 0),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              article['title'] ?? 'No title',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              article['description'] ?? 'No description',
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article['source']?['name'] ?? 'Unknown',
                  style: TextStyle(color: Colors.blue[700], fontSize: 12),
                ),
                Text(
                  article['publishedAt'] != null
                      ? DateFormat('MMM dd, HH:mm').format(DateTime.parse(article['publishedAt']))
                      : '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              return _buildChatBubble(msg);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isMe = msg.user == 'You';
    final isSignal = msg.isSignal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) CircleAvatar(child: Text(msg.user.substring(0, 1))),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSignal
                    ? Colors.amber.withValues(alpha: 0.2)
                    : (isMe ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
                border: isSignal ? Border.all(color: Colors.amber) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.user,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSignal ? Colors.amber[800] : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(msg.message),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(msg.timestamp),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: const InputDecoration(
                hintText: 'Share your trading idea...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        ChatService.addMessage('You', _chatController.text);
        _chatMessages = ChatService.getMessages();
        _chatController.clear();
      });
    }
  }

  Widget _buildLearningTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📚 Learning Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildLessonItem('1', 'Forex Basics', 'Learn what forex trading is and how it works.', Icons.book),
                _buildLessonItem('2', 'Risk Management', 'Protect your capital with proper risk strategies.', Icons.shield),
                _buildLessonItem('3', 'Trading Psychology', 'Master your emotions for better trading.', Icons.psychology),
                _buildLessonItem('4', 'Strategies', 'Learn scalping, swing trading, and more.', Icons.build),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 Quick Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('• Never risk more than 1-2% per trade', style: TextStyle(fontSize: 14)),
                const Text('• Always use stop-loss orders', style: TextStyle(fontSize: 14)),
                const Text('• Follow the trend, not your emotions', style: TextStyle(fontSize: 14)),
                const Text('• This app is a tool, not financial advice', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonItem(String number, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
