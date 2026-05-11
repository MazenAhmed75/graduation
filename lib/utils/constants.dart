/// App-wide constants.
/// WARNING: Never commit real keys to a public repository.
class AppConstants {
  // ── Groq AI (OpenAI-compatible, free tier, ultra-fast LPU) ───────────────
  static const String aiApiKey  = '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';
  static const String aiBaseUrl = 'https://api.groq.com/openai/v1';
  static const String aiModel   = 'llama-3.3-70b-versatile';


  // ── Free Market Data APIs ─────────────────────────────────────────────────
  // CoinGecko — crypto prices (free, no auth)
  static const String coinGeckoBase = 'https://api.coingecko.com/api/v3';

  // metals.live — gold/silver spot price (free, no auth)
  static const String metalsBase = 'https://api.metals.live/v1/spot';

  // Finnhub — US stock quotes (free tier, 60 req/min)
  // Get a free key at: https://finnhub.io/register
  static const String finnhubBase   = 'https://finnhub.io/api/v1';
  static const String finnhubApiKey = 'd0sc31pr01qhkqg9p7bgd0sc31pr01qhkqg9p7c0'; // free demo key

  // ── Supported Asset IDs ───────────────────────────────────────────────────
  static const List<String> cryptoIds = [
    'bitcoin', 'ethereum', 'binancecoin', 'solana', 'ripple',
  ];
  static const List<String> metalIds  = ['gold', 'silver'];

  // Stock tickers to track via Finnhub
  static const List<String> stockTickers = [
    'AAPL', 'TSLA', 'NVDA', 'MSFT', 'AMZN', 'GOOGL', 'META', 'SPY',
  ];
}
