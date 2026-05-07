# Forex Trading App - Chat Summary

## 🎯 Project Goal
Build a forex trading app for Zimbabwe market that:
- Analyzes when to trade
- Shows trading signals (BUY/SELL)
- Explains advantages/disadvantages of trades
- Includes real news and trader chat

## 📁 Repository
**GitHub:** https://github.com/guvazakundai-pixel/forex_trading_app

## ✅ Features Implemented

### Core Features
1. **Live Forex Rates** - ExchangeRate-API (free, no rate limits)
2. **Trading Signals** - RSI + Moving Averages (5, 10, 30 day)
3. **Signal Types:** STRONG BUY, BUY, STRONG SELL, SELL, HOLD
4. **Confidence %** - Dynamic (50-95%) based on RSI values
5. **Entry/SL/TP** - Auto-calculated with risk levels

### Educational Features
6. **Signal Explanations** - What each signal means
7. **Trade Advantages/Risks** - Expanded details for each trade type
8. **Learning Hub** - Forex basics, Risk management, Psychology, Strategies
9. **About Page** - Full app guide and disclaimer

### Community Features
10. **Trader Chat** - Candlestick-style (green/red bubbles)
11. **Signal Bot** - Auto-posts signals to chat
12. **Timeline** - "Just now", "5m ago", "2h ago" timestamps

### Data & Persistence
13. **SQLite Database** - Persists chat messages and trade history
14. **Trade History Screen** - View all past trades
15. **User Settings** - Ready for preferences storage

### Advanced Features (Code Ready)
16. **Alert Service** - Price alerts and push notifications
17. **Calculator Service** - Position sizing based on risk %
18. **Sentiment Analysis** - Market sentiment from news
19. **Backtesting Service** - Test strategies on historical data
20. **Multi-timeframe** - 1D, 1H, 5m (UI ready)

## 🔑 API Keys Needed
1. **Alpha Vantage** (forex rates & historical data)
   - Get free: https://www.alphavantage.co/support/#api-key
   - Add to: `lib/services/api_config.dart`

2. **NewsAPI** (real forex news)
   - Get free: https://newsapi.org/register
   - Add to: `lib/services/news_service.dart`

## 🛠️ Tech Stack
- **Flutter** 3.41.9 (stable)
- **Dart** 3.11.5
- **Packages:** http, fl_chart, intl, sqflite, path_provider, flutter_local_notifications
- **Database:** SQLite (via sqflite)

## 🚀 How to Run on BlackArch
```bash
# Clone the repository
git clone https://github.com/guvazakundai-pixel/forex_trading_app.git
cd forex_trading_app

# Install dependencies
flutter pub get

# Run on Chrome (easiest)
flutter run -d chrome

# For Android emulator:
flutter emulators --launch <emulator_id>
```

## 💰 Monetization Plan
1. **Free Version:** 2 signals/day, basic learning
2. **Premium ($10-50/month):** Unlimited signals, advanced AI, real-time alerts
3. **VIP ($100+/month):** High-accuracy signals, mentorship, copy trading

## ⚠️ Important Notes
- App is a **tool**, NOT financial advice
- Always use stop-loss orders
- Never risk more than 1-2% per trade
- Zimbabwe-specific: Supports USD/ZWL pair

## 📝 Git Commit History
```bash
git log --oneline
# ace781a Initial commit: Forex trading app with API integration and trading signals
# 3e0238a Add: Signal explanations, trade advantages/risks, learning hub, enhanced dashboard
# b112716 Update: Candlestick-style chat with green/red signals, timeline, and improved UI
# 55c1250 Add: alerts, calculator, sentiment analysis, backtesting, risk management features
```

## 🎯 Next Steps on BlackArch
1. Add MACD, Bollinger Bands indicators
2. Implement economic calendar
3. Add copy trading feature
4. Deploy to Google Play Store ($25 fee)
5. Set up push notification server

---
**Chat Date:** May 5-6, 2026
**User:** guvazakundai-pixel
**Model:** opencode/big-pickle
