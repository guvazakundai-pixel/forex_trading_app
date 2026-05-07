class BacktestResult {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double profitFactor;
  final double averageWin;
  final double averageLoss;
  final double netProfit;

  BacktestResult({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.profitFactor,
    required this.averageWin,
    required this.averageLoss,
    required this.netProfit,
  });
}

class BacktestService {
  // Simulate backtesting on historical data
  static BacktestResult backtestStrategy({
    required List<double> prices,
    required List<String> signals, // BUY, SELL, HOLD
    double initialBalance = 10000,
    double lotSize = 0.1,
    double pipValue = 10.0,
  }) {
    double balance = initialBalance;
    int wins = 0;
    int losses = 0;
    double totalWin = 0;
    double totalLoss = 0;
    double? openPrice;
    String? openType;

    for (int i = 0; i < prices.length - 1; i++) {
      final signal = signals[i];
      final price = prices[i];

      if (signal == 'BUY' && openType == null) {
        openPrice = price;
        openType = 'BUY';
      } else if (signal == 'SELL' && openType == null) {
        openPrice = price;
        openType = 'SELL';
      } else if (openType != null) {
        // Simple exit logic: close on opposite signal or after 5 periods
        bool shouldClose = (openType == 'BUY' && signal == 'SELL') ||
            (openType == 'SELL' && signal == 'BUY') ||
            i % 5 == 0;

        if (shouldClose) {
          final closePrice = price;
          final pipChange = openType == 'BUY'
              ? (closePrice - openPrice!) * 10000
              : (openPrice! - closePrice) * 10000;

          final profit = pipChange * (lotSize * pipValue);
          balance += profit;

          if (profit > 0) {
            wins++;
            totalWin += profit;
          } else {
            losses++;
            totalLoss += profit.abs();
          }

          openPrice = null;
          openType = null;
        }
      }
    }

    final winRate = wins + losses > 0 ? (wins / (wins + losses)) * 100 : 0;
    final avgWin = wins > 0 ? totalWin / wins : 0;
    final avgLoss = losses > 0 ? totalLoss / losses : 0;
    final profitFactor = avgLoss > 0 ? avgWin / avgLoss : 0;

    return BacktestResult(
      totalTrades: wins + losses,
      winningTrades: wins,
      losingTrades: losses,
      winRate: winRate,
      profitFactor: profitFactor,
      averageWin: avgWin,
      averageLoss: avgLoss,
      netProfit: balance - initialBalance,
    );
  }

  static String generateReport(BacktestResult result) {
    return '''
Backtest Results:
==================
Total Trades: ${result.totalTrades}
Winning Trades: ${result.winningTrades}
Losing Trades: ${result.losingTrades}
Win Rate: ${result.winRate.toStringAsFixed(1)}%
Net Profit: \$${result.netProfit.toStringAsFixed(2)}
Profit Factor: ${result.profitFactor.toStringAsFixed(2)}
Average Win: \$${result.averageWin.toStringAsFixed(2)}
Average Loss: \$${result.averageLoss.toStringAsFixed(2)}
''';
  }
}
