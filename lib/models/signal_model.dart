class TradeSignal {
  final String pair;
  final String type; // BUY or SELL
  final double entryPrice;
  final double stopLoss;
  final double takeProfit;
  final double confidence; // 0-100%
  final String riskLevel; // Low, Medium, High
  final String reason;

  TradeSignal({
    required this.pair,
    required this.type,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidence,
    required this.riskLevel,
    required this.reason,
  });

  factory TradeSignal.fromSignal(String pair, String signal, double currentRate) {
    final isBuy = signal.contains('BUY');
    final isStrong = signal.contains('STRONG');
    
    // Calculate suggested levels based on current rate
    final entry = currentRate;
    final stopLoss = isBuy 
        ? entry * 0.997  // 0.3% stop loss for buy
        : entry * 1.003; // 0.3% stop loss for sell
    final takeProfit = isBuy
        ? entry * (isStrong ? 1.01 : 1.005)  // 1% or 0.5% TP
        : entry * (isStrong ? 0.99 : 0.995); // 1% or 0.5% TP
    
    final confidence = signal.contains('STRONG') ? 85.0 : 70.0;
    final risk = signal.contains('STRONG') ? 'Low' : 'Medium';
    
    return TradeSignal(
      pair: pair,
      type: isBuy ? 'BUY' : 'SELL',
      entryPrice: entry,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence,
      riskLevel: risk,
      reason: signal,
    );
  }
}
