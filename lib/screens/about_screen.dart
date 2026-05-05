import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Forex Signals'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Forex Trading Signals',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
                  const Text(
                    'What This App Does',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    Icons.show_chart,
                    'Live Forex Rates',
                    'Get real-time exchange rates for major currency pairs including EUR/USD, GBP/USD, USD/JPY, and more.',
                  ),
                  _buildFeatureItem(
                    Icons.notifications_active,
                    'Trading Signals',
                    'Receive STRONG BUY, BUY, SELL, and HOLD signals based on RSI and Moving Average analysis.',
                  ),
                  _buildFeatureItem(
                    Icons.lightbulb_outline,
                    'Signal Explanations',
                    'Each signal comes with detailed explanation of what it means and how to act on it.',
                  ),
                  _buildFeatureItem(
                    Icons.check_circle,
                    'Trade Advantages & Risks',
                    'Learn the advantages of good trades and risks of bad trades to make informed decisions.',
                  ),
                  _buildFeatureItem(
                    Icons.newspaper,
                    'Real-Time News',
                    'Stay updated with the latest forex news that can impact currency movements.',
                  ),
                  _buildFeatureItem(
                    Icons.chat,
                    'Trader Chat',
                    'Connect with other traders, share ideas, and discuss market movements in real-time.',
                  ),
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
                  const Text(
                    'How to Use This App',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStepItem('1', 'Select Currency Pair', 'Choose from EUR/USD, GBP/USD, USD/JPY, or USD/ZWL'),
                  _buildStepItem('2', 'Get Trading Signal', 'Click "Fetch Rate" to see current signal with RSI and moving averages'),
                  _buildStepItem('3', 'Understand the Signal', 'Read the explanation to know what the signal means and how to trade'),
                  _buildStepItem('4', 'Check the News', 'Switch to News tab to see market events that may affect your trade'),
                  _buildStepItem('5', 'Join the Discussion', 'Chat with other traders to get insights and share your analysis'),
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
                  const Text(
                    '⚠️ Important Disclaimer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This app provides technical analysis tools and educational content. It is NOT financial advice. Always:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Do your own research before trading', style: TextStyle(fontSize: 13)),
                  const Text('• Never invest more than you can afford to lose', style: TextStyle(fontSize: 13)),
                  const Text('• Use stop-loss orders to manage risk', style: TextStyle(fontSize: 13)),
                  const Text('• Consider consulting a financial advisor', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  Text(
                    'Trading forex involves substantial risk of loss. Past performance is not indicative of future results.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Made with ❤️ for Zimbabwe traders',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '© 2026 Forex Trading Signals',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
