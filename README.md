# Atlas AI Trading Terminal

**Atlas AI Trading Terminal** is a professional-grade, quantitative AI-assisted trading analysis web application engineered for **Forex, Gold (XAU/USD), and Cryptocurrencies**. It integrates real-time market feeds, validated technical indicators, machine-learning probabilistic forecasts, rule-based strategy alignment, institutional risk management, event-driven historical walk-forward backtesting, and a persistent paper-trading simulator.

---

## 1. System Architecture

```
                    ┌────────────────────────────────────────────────────────┐
                    │               Atlas AI Trading Terminal UI             │
                    │      (React 19, Vite, TypeScript, Tailwind CSS,        │
                    │        TradingView Lightweight Charts v5)              │
                    └───────────────────────────┬────────────────────────────┘
                                                │ REST API / Vite Proxy
                                                ▼
                    ┌────────────────────────────────────────────────────────┐
                    │                 FastAPI Backend Server                 │
                    │          (Python 3.11, pandas, NumPy, scikit-learn)    │
                    └───────┬────────────┬─────────────┬─────────────┬───────┘
                            │            │             │             │
        ┌───────────────────┴──┐  ┌──────┴─────────┐  ┌┴──────────┐ ┌┴───────────────────┐
        │  Market Data Service │  │  Indicators &  │  │ ML Engine │ │ Strategy & Decision │
        │  • Binance Live      │  │  Feature Pipe  │  │ • HistGBM │ │ • Higher TF Trend   │
        │  • Twelve Data       │  │  • EMA/RSI/MACD│  │ • LogReg  │ │ • Lower TF Pullback │
        │  • Calibrated Demo   │  │  • ADX/HA/ATR  │  │ • Calibr. │ │ • Safety Filters    │
        └──────────────────────┘  └────────────────┘  └───────────┘ └─────────┬─────────┘
                                                                               │
                                  ┌────────────────────────────────────────────┼───────────────────────────┐
                                  ▼                                            ▼                           ▼
                    ┌────────────────────────────┐               ┌──────────────────────────┐ ┌─────────────────────────┐
                    │      AI Explainer          │               │     Risk Management      │ │   Backtest & Paper DB   │
                    │  • Structured Analytical   │               │  • Asset-specific sizing │ │  • Walk-Forward Engine  │
                    │    Briefings (JSON & text) │               │  • Forex, Gold, Crypto   │ │  • SQLite WAL database  │
                    │  • Non-hallucinatory facts │               │  • Daily loss limits     │ │  • Next-bar Open exec   │
                    └────────────────────────────┘               └──────────────────────────┘ └─────────────────────────┘
```

---

## 2. Supported Markets & Specifications

| Market Symbol | Asset Class | Contract Size / Lot | Tick / Pip Size | Pip Value (1.0 Lot) | Default Spread | Max Leverage |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **EUR/USD** | Forex | 100,000 EUR | 0.0001 (1 Pip) | $10.00 / pip | 1.2 Pips | 30:1 |
| **GBP/USD** | Forex | 100,000 GBP | 0.0001 (1 Pip) | $10.00 / pip | 1.6 Pips | 30:1 |
| **USD/JPY** | Forex | 100,000 USD | 0.01 (1 Pip) | ~$6.55 / pip (dynamic) | 1.5 Pips | 30:1 |
| **AUD/USD** | Forex | 100,000 AUD | 0.0001 (1 Pip) | $10.00 / pip | 1.5 Pips | 30:1 |
| **USD/CHF** | Forex | 100,000 USD | 0.0001 (1 Pip) | $10.00 / pip | 1.6 Pips | 30:1 |
| **XAU/USD** | Commodity | 100 Troy Oz | $0.01 | $100.00 / $1.00 move | $0.25 | 20:1 |
| **BTC/USDT** | Crypto | 1.0 Bitcoin | $0.01 | $1.00 / $1.00 move | $1.00 | 5:1 |
| **ETH/USDT** | Crypto | 1.0 Ether | $0.01 | $1.00 / $1.00 move | $0.15 | 5:1 |

Available Timeframes: `1m`, `5m`, `15m`, `1h`, `4h`, `1d`.

---

## 3. Core Capabilities

### A. Market Data Integration
- **Cryptocurrency (`BTC/USDT`, `ETH/USDT`)**: Directly pulls real-time historical and live klines from the **Binance Public API** (no registration or API key required).
- **Forex & Gold (`EUR/USD`, `GBP/USD`, `USD/JPY`, `AUD/USD`, `USD/CHF`, `XAU/USD`)**: Integrates with **Twelve Data API**.
- **Transparent Fallback Mode**: If API credentials or Internet connectivity are absent, Atlas automatically activates a high-fidelity synthetic market generator calibrated to real asset prices, and **prominently displays `Atlas Synthetic Market Engine (Demo Fallback)` and `is_simulated: true` badges**. Simulated data is never disguised as live data.

### B. Machine Learning Engine
- Compares an L2-regularized **Logistic Regression** baseline with **HistGradientBoostingClassifier**.
- **Point-in-Time Features**: Strict chronological feature engineering without lookahead bias:
  - Exponential Moving Averages: EMA 50, EMA 200, EMA spread, and price distance ratios.
  - Volatility: Average True Range (ATR) and Normalized ATR (% of price).
  - Directional Force: ADX, +DI, -DI, and directional spread.
  - Oscillators: Wilder-smoothed RSI (14) normalized around zero.
  - Trend Momentum: MACD line, signal line, and histogram normalized by price.
  - Microstructure: Candle body ratio, upper wick ratio, lower wick ratio, and Heikin Ashi direction.
  - Market Regime: Categorizes into *Trending Bullish*, *Trending Bearish*, *Ranging High Volatility*, or *Ranging Low Volatility*.
- **Multi-Class Adaptive Labels**: Constructs future targets over $H$ bars (default 5 bars) based on adaptive ATR volatility boundaries: `Bullish (+1)`, `Bearish (-1)`, or `Neutral (0)`.
- **Probability Calibration**: Uses `CalibratedClassifierCV` (sigmoid) on chronological validation splits to produce well-calibrated probabilities, reporting out-of-sample test accuracy and Brier calibration loss.
- **Fail-Safe Mechanism**: If out-of-sample accuracy fails to exceed baseline or test samples are insufficient, output displays `MODEL_NOT_VALIDATED` and blocks automated execution.

### C. Rule-Based Strategy & Transparent Decision Engine
- **Higher Timeframe Trend Structure**:
  - Bullish Structure: EMA 50 > EMA 200 and ADX >= 20.
  - Bearish Structure: EMA 50 < EMA 200 and ADX >= 20.
- **Lower Timeframe Pullback & Continuation**:
  - Evaluates pullbacks towards EMA 50 within configurable ATR tolerance.
  - Triggers only when candle closes with Heikin Ashi color change and directional DI alignment.
- **Transparent Fused Decision Engine**:
  - Combines Rule setup with ML probability.
  - Candidate technical setups are rejected if ML confidence is below threshold, if the model predicts the opposing direction, or if market regime is adverse.
  - Generates clear statuses: `CONFIRMED`, `REJECTED`, or `NEUTRAL`.

### D. Institutional Risk Management
- **Instrument-Specific Sizing**:
  - Forex: Computes exact lot sizing based on pip risk and quote currency value per standard 100k lot.
  - Gold: Computes ounces / 100 oz contract lots based on monetary risk.
  - Crypto: Computes fractional coin units.
- **Hard Safety Limits**:
  - Configurable risk percentage per trade (e.g., 1.5% of equity).
  - Maximum daily loss limit (e.g., 5.0% of equity) — blocks further orders once reached.
  - Maximum concurrent open positions (e.g., 4).
  - Minimum Risk/Reward ratio verification (minimum 1:1.5 required).

### E. Event-Driven Walk-Forward Backtesting
- **Zero Lookahead Bias**: Generates signals on candle $t$ close and strictly executes on candle $t+1$ Open.
- **Realistic Friction**: Deducts configurable spread, slippage, and taker commission.
- **Conservative Intra-Candle Handling**: If both Stop Loss and Take Profit levels fall within the same bar's High/Low extremes, the simulator assumes the Stop Loss was hit first (worst-case).
- **Comprehensive Analytics**: Win Rate, Profit Factor, Expectancy per trade, Maximum Drawdown ($ and %), Sharpe Ratio, Equity Curve time-series, and baseline Buy-and-Hold comparison.

### F. Paper Trading Simulator
- Virtual account with persistent $100,000 USD starting balance in SQLite (`trading_terminal.db`).
- Real-time mark-to-market unrealized and realized P&L calculations.
- Automatic SL and TP trigger checks against incoming ticks/candles.
- One-click position closure and account reset.
- *Live broker order dispatch is disabled by design.*

---

## 4. Quick Start & Windows PowerShell Commands

### Prerequisites
- Node.js (v18+)
- Python (v3.11+)

### A. Run Backend Unit Test Suite
To run the automated test suite verifying indicators, risk sizing, ML calibration, and zero-lookahead bias:
```powershell
# Set PYTHONPATH and run pytest
$env:PYTHONPATH = "d:\trading\backend"
& "C:\Users\arsis\Python311\python.exe" -m pytest backend/tests -v
```

### B. Launch Application
You can run the full terminal using the provided scripts or manually in two terminals:

#### Method 1: One-Click Launch Script
Double-click `run_all.bat` or execute in PowerShell:
```powershell
.\run_all.ps1
```

#### Method 2: Manual Terminal Commands
**Terminal 1 (Backend API):**
```powershell
cd d:\trading\backend
$env:PYTHONPATH = "d:\trading\backend"
& "C:\Users\arsis\Python311\python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

**Terminal 2 (Frontend Dashboard):**
```powershell
cd d:\trading\frontend
npm.cmd run dev
```

Open your browser to: **http://127.0.0.1:5173**

---

## 5. API Key Configuration

Copy `backend/.env.example` to `backend/.env`:
```ini
# Twelve Data API Key (Optional for live Forex & Gold)
# Free registration at https://twelvedata.com
TWELVE_DATA_API_KEY=your_twelve_data_key_here

# Optional LLM API Key (For enhanced natural language synthesis)
OPENAI_API_KEY=
GROQ_API_KEY=
GEMINI_API_KEY=
```

> **Note:**
> If `TWELVE_DATA_API_KEY` is not provided, the terminal automatically runs in **Demo / Calibrated Synthetic Mode** for Forex and Gold, while cryptocurrency pairs continue streaming live from Binance without requiring any keys.

---

## 6. Implementation Checklist

| Stage | Feature / Component | Status | Notes |
| :--- | :--- | :---: | :--- |
| **Stage 1** | Dark Trading Dashboard UI | ✅ Implemented | Professional navy theme (`#080b10`), clean typography, responsive layout |
| **Stage 1** | Searchable Watchlist | ✅ Implemented | EUR/USD, GBP/USD, USD/JPY, AUD/USD, USD/CHF, XAU/USD, BTC/USDT, ETH/USDT |
| **Stage 1** | Interactive Candlestick Chart | ✅ Implemented | TradingView Lightweight Charts v5 with crosshair tooltips |
| **Stage 2** | Technical Indicators | ✅ Implemented | EMA 50, EMA 200, RSI (14), MACD, ATR, ADX (+DI/-DI), Heikin Ashi, Volume |
| **Stage 2** | Rule-Based Strategy | ✅ Implemented | Higher TF trend structure + Lower TF pullback entries on closed candles |
| **Stage 3** | FastAPI Backend | ✅ Implemented | Documented endpoints: `/api/markets`, `/api/candles`, `/api/health`, etc. |
| **Stage 3** | Market Data Integration | ✅ Implemented | Binance live public API + Twelve Data + calibrated synthetic fallback |
| **Stage 4** | Machine Learning Pipeline | ✅ Implemented | HistGradientBoosting vs Logistic Regression with Sigmoid calibration |
| **Stage 4** | No-Data-Leakage Guarantee | ✅ Implemented | Strict point-in-time features; verified via automated unit test |
| **Stage 5** | AI Signal Explanation | ✅ Implemented | Structured JSON output + quantitative executive summary |
| **Stage 5** | Institutional Risk Manager | ✅ Implemented | Asset-specific contract/lot sizing, max daily loss limit, margin checks |
| **Stage 6** | Walk-Forward Backtester | ✅ Implemented | Next-bar Open execution, conservative intra-candle SL, equity curve |
| **Stage 6** | Paper Trading Simulator | ✅ Implemented | SQLite persistent accounts ($100k), open positions, automated SL/TP |
| **Stage 7** | Automated Test Suite | ✅ Implemented | 6 comprehensive pytest tests passing in `backend/tests/` |
| **Stage 7** | Windows Scripts & Documentation | ✅ Implemented | `run_all.bat`, `run_all.ps1`, `run_backend.ps1`, `run_frontend.ps1` |

---

## 7. Regulatory & Safety Disclaimer

**Atlas AI Trading Terminal** is an educational, quantitative research and simulation workstation. Machine learning predictions, statistical probabilities, and rule-based strategies are mathematical models based on historical price behavior and do not guarantee future profits or market direction. Trading Forex, Commodities, and Cryptocurrencies involves substantial risk of financial loss.
