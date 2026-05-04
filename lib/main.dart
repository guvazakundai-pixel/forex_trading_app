import 'package:flutter/material.dart';
import 'services/forex_service.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
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
  bool _isLoading = false;
  String _selectedPair = 'EUR/USD';

  final List<String> _pairs = ['EUR/USD', 'GBP/USD', 'USD/JPY', 'USD/ZWL'];

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    String from = _selectedPair.split('/')[0];
    String to = _selectedPair.split('/')[1];
    
    final currentData = await ForexService.fetchForexRate(from, to);
    final historicalData = await ForexService.fetchForexTimeSeries(from, to);
    
    setState(() {
      _forexData = currentData;
      _historicalData = historicalData;
      _isLoading = false;
    });
  }

  String _getSignal() {
    if (_historicalData == null) return 'Fetch data to see signal';
    return ForexService.generateSignal(_historicalData!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forex Trading Signals'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: _selectedPair,
              isExpanded: true,
              onChanged: (value) => setState(() => _selectedPair = value!),
              items: _pairs.map((pair) => DropdownMenuItem(
                value: pair,
                child: Text(pair),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchData,
              child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Fetch Rate'),
            ),
            const SizedBox(height: 20),
            if (_forexData != null) _buildForexDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildForexDisplay() {
    final rateData = _forexData!['Realtime Currency Exchange Rate'];
    if (rateData == null) return const Text('No data available');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pair: ${rateData['1. From_Currency Code']}/${rateData['3. To_Currency Code']}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Rate: ${rateData['5. Exchange Rate']}',
                style: const TextStyle(fontSize: 24, color: Colors.green)),
            Text('Last Update: ${rateData['6. Last Refreshed']}'),
            const SizedBox(height: 20),
            _buildSignal(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignal() {
    final signal = _getSignal();
    final isBuy = signal.contains('BUY');
    final isSell = signal.contains('SELL');
    final color = isBuy ? Colors.green : (isSell ? Colors.red : Colors.blue);
    final icon = isBuy ? Icons.trending_up : (isSell ? Icons.trending_down : Icons.info);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(signal, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
