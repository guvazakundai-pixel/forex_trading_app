import 'package:flutter/material.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            '📚 Forex Basics',
            'Learn the fundamentals of forex trading',
            [
              _buildLesson('What is Forex?', 'Forex (foreign exchange) is the market where currencies are traded.', Icons.info),
              _buildLesson('Currency Pairs', 'Currencies are traded in pairs like EUR/USD. The first is base, second is quote.', Icons.currency_exchange),
              _buildLesson('Pips & Lots', 'A pip is the smallest price movement. A lot is the size of your trade.', Icons.bar_chart),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            '🛡️ Risk Management',
            'Protect your capital - the most important skill',
            [
              _buildLesson('1% Rule', 'Never risk more than 1-2% of your account on a single trade.', Icons.warning),
              _buildLesson('Stop Loss', 'Always set a stop-loss order to limit potential losses.', Icons.block),
              _buildLesson('Position Sizing', 'Calculate lot size based on your risk tolerance and stop distance.', Icons.calculate),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            '🧠 Trading Psychology',
            'Master your mind for consistent profits',
            [
              _buildLesson('Control Emotions', 'Fear and greed are traders\' worst enemies. Stick to your plan.', Icons.psychology),
              _buildLesson('Patience', 'Wait for high-probability setups. Not trading is also a position.', Icons.hourglass_empty),
              _buildLesson('Discipline', 'Follow your trading plan regardless of market noise.', Icons.check_circle),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            '🎯 Strategies',
            'Proven trading methods for different styles',
            [
              _buildLesson('Scalping', 'Quick trades lasting seconds to minutes. High frequency, small profits.', Icons.flash_on),
              _buildLesson('Swing Trading', 'Hold trades for days to capture medium-term price moves.', Icons.trending_up),
              _buildLesson('Position Trading', 'Long-term approach based on fundamental analysis.', Icons.calendar_today),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  const Text(
                    'Pro Tip',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Success in forex comes from education, discipline, and proper risk management. This app is a tool to help you learn and analyze - always do your own research before trading.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> lessons) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 16),
            ...lessons,
          ],
        ),
      ),
    );
  }

  Widget _buildLesson(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
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
}
