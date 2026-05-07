class CalculatorService {
  // Calculate position size based on risk
  static double calculatePositionSize({
    required double accountBalance,
    required double riskPercent,
    required double entryPrice,
    required double stopLoss,
    required double pipValue = 10.0, // $10 per pip per lot (standard)
  }) {
    final riskAmount = accountBalance * (riskPercent / 100);
    final stopDistance = (entryPrice - stopLoss).abs();
    final pipDistance = stopDistance * 10000; // Convert to pips for most pairs
    final positionSize = riskAmount / (pipDistance * pipValue / 1000);
    return positionSize.clamp(0.01, 100.0); // Min 0.01 lot
  }

  // Calculate profit/loss
  static double calculateProfitLoss({
    required double entryPrice,
    required double closePrice,
    required double positionSize, // in lots
    required String type, // BUY or SELL
    double pipValue = 10.0,
  }) {
    final pipChange = type == 'BUY'
        ? (closePrice - entryPrice) * 10000
        : (entryPrice - closePrice) * 10000;
    return pipChange * (positionSize * pipValue);
  }

  // Calculate risk-reward ratio
  static double calculateRiskReward({
    required double entryPrice,
    required double stopLoss,
    required double takeProfit,
  }) {
    final risk = (entryPrice - stopLoss).abs();
    final reward = (takeProfit - entryPrice).abs();
    return reward / risk;
  }

  // Format as currency
  static String formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(2)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }
}
