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
    
    // Extract RSI value from signal string
    final rsiMatch = RegExp(r'RSI:\s*(\d+\.?\d*)').firstMatch(signal);
    double rsi = 50.0;
    if (rsiMatch != null) {
      rsi = double.tryParse(rsiMatch.group(1)!) ?? 50.0;
    }
    
    // Calculate dynamic confidence based on RSI and signal type
    double confidence = 0.0;
    if (signal.contains('STRONG BUY')) {
      confidence = 85.0 + (rsi < 30 ? 10 : 0); // Up to 95% if RSI very oversold
    } else if (signal.contains('BUY')) {
      confidence = 65.0 + (rsi < 35 ? 10 : 0); // Up to 75%
    } else if (signal.contains('STRONG SELL')) {
      confidence = 85.0 + (rsi > 70 ? 10 : 0); // Up to 95% if RSI very overbought
    } else if (signal.contains('SELL')) {
      confidence = 65.0 + (rsi > 65 ? 10 : 0); // Up to 75%
    } else {
      confidence = 50.0; // HOLD
    }
    
    // Calculate suggested levels based on current rate
    final entry = currentRate;
    final stopLoss = isBuy 
        ? entry * 0.997  // 0.3% stop loss for buy
        : entry * 1.003; // 0.3% stop loss for sell
    final takeProfit = isBuy
        ? entry * (isStrong ? 1.01 : 1.005)  // 1% or 0.5% TP
        : entry * (isStrong ? 0.99 : 0.995); // 1% or 0.5% TP
    
    final risk = confidence > 80 ? 'Low' : (confidence > 70 ? 'Medium' : 'High');
    
    return TradeSignal(
      pair: pair,
      type: isBuy ? 'BUY' : 'SELL',
      entryPrice: entry,
      stopLoss: stopLoss,
      takeProfit: takeProfit,
      confidence: confidence.clamp(50.0, 95.0),
      riskLevel: risk,
      reason: signal,
    );
  }
}
