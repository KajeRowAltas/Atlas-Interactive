# AI-Driven Cryptocurrency Scalp Trading Bot

This repository contains the source code for an experimental, AI-driven cryptocurrency trading application designed for automated, high-frequency scalp trading on the MEXC exchange. The system executes high-leverage futures trades based on technical indicators and features a remote-view interface for real-time AI analysis.

---

### **Table of Contents**
1.  [Project Rationale](#project-rationale)
2.  [Key Features](#key-features)
3.  [Strategy Overview](#strategy-overview)
4.  [Growth & Capital Management Milestones](#growth--capital-management-milestones)
5.  [Risk Warnings and Disclaimers](#risk-warnings-and-disclaimers)
6.  [Setup Instructions](#setup-instructions)
7.  [Development Status & Backtesting](#development-status--backtesting)
8.  [Future Roadmap](#future-roadmap)
9.  [License](#license)

---

### **Project Rationale**

This project serves as an analytical exploration into the efficacy of aggressive, indicator-based scalp trading strategies in highly volatile markets. The primary goal is to quantitatively assess the performance of an automated system that applies a rigid set of rules to memecoin (DOGE/USDT, PEPE/USDT) and major-pair (BTC/USDT) perpetual futures. The integration of an AI for real-time chart analysis is intended to research the potential for data-driven, automated decision-making in high-risk trading environments.

### **Key Features**

*   **Automated Scalp Trading Bot**: Executes trades based on predefined logic without manual intervention.
*   **AI-Integrated Chart Analysis**: An integrated AI is capable of "seeing" and analyzing live TradingView charts and indicators in real-time, providing a basis for data-driven decision-making or oversight.
*   **Live Trading Visualization**: The interface provides a real-time view of charts and active indicators, mirroring what the AI analyzes.
*   **MEXC Futures Integration**: Natively connects to the MEXC exchange API to manage and execute perpetual futures trades.

### **Strategy Overview**

The bot's logic is designed to be purely data-driven and operates under a strict, predefined ruleset.

*   **Asset Universe**: The bot exclusively trades perpetual futures on three pairs: `BTC/USDT`, `DOGE/USDT`, and `PEPE/USDT`.
*   **Pair Selection**: The system dynamically switches between pairs based on an analysis of current liquidity and volatility to identify the most opportune market conditions.
*   **Position Sizing**: **The bot is programmed to use the maximum available margin for each trade ("all-in" positioning).** This strategy is designed to maximize capital velocity but carries an extreme risk of rapid, total account liquidation.
*   **Entry Logic**: The bot activates and enters a long position only when a confluence of technical indicators signals a high probability of an imminent uptrend. Key indicators include:
    *   Relative Strength Index (RSI)
    *   Moving Average Convergence Divergence (MACD)
    *   Bollinger Bands
    *   Volume Profile Visible Range (VPVR)
*   **Exit Logic**: A position is automatically closed based on one of the following prioritized conditions:
    1.  Reversal signals from the core technical indicators.
    2.  Achievement of a predefined small profit target (characteristic of scalping).
    3.  Activation of a strict stop-loss condition to mitigate downside exposure.

### **Growth & Capital Management Milestones**

The following table outlines the projected capital growth targets and planned withdrawals. This structure is designed for disciplined capital management, assuming the strategy performs as modeled. **These are theoretical targets, not guarantees of performance.**

| Milestone | Starting Capital | Target Capital | Withdrawal |
| :-------- | :--------------- | :------------- | :--------- |
| 1         | $1               | $1,000         | $0         |
| 2         | $1,000           | $2,000         | $0         |
| 3         | $2,000           | $2,800         | $800       |
| 4         | $2,000           | $5,000         | $0         |
| 5         | $5,000           | $10,000        | $0         |
| 6         | $10,000          | $20,000        | $0         |
| 7         | $20,000          | $50,000        | $5,000     |
| 8         | $45,000          | $80,000        | $0         |
| 9         | $80,000          | $100,000       | $0         |
| 10        | $100,000         | $200,000       | $0         |
| 11        | $200,000         | $500,000       | $0         |
| 12        | $500,000         | $1,000,000     | $50,000    |


### **Risk Warnings and Disclaimers**

**This section contains critical warnings. Read it carefully before proceeding.**

*   **EXPERIMENTAL SOFTWARE**: This is experimental software intended for educational and research purposes only. It is not financial advice.
*   **EXTREME RISK OF LOSS**: Cryptocurrency trading, particularly high-leverage futures scalping, involves an extreme degree of risk. You may lose your entire invested capital. The high frequency of trades can also lead to significant capital erosion through fees.
*   **"ALL-IN" STRATEGY**: The strategy's use of all-in positioning is exceptionally high-risk and can lead to the immediate and total liquidation of your account balance in a single adverse market movement.
*   **REGULATORY WARNING (MEXC)**: As of September 2025, the Dutch Authority for the Financial Markets (AFM) has issued a warning that MEXC operates without the required legal authorization in the Netherlands and, by extension, the EU under MiCAR. This means the exchange offers no consumer protections, and users have no recourse in the event of disputes or losses.
*   **NO GUARANTEE OF PROFITABILITY**: There are no guarantees of profitability. Historical performance, backtesting results, and projected milestones are not indicative of future results.
*   **LEGAL & TAX COMPLIANCE**: You are solely responsible for ensuring that your use of this software complies with all local laws, regulations, and tax obligations in your jurisdiction. The developer assumes absolutely no liability for any financial losses, legal issues, or other damages incurred.

### **Setup Instructions**

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```
2.  **Install dependencies:**
    ```bash
    # (e.g., pip install -r requirements.txt)
    # Add dependency installation instructions here.
    ```
3.  **Configure API Keys:**
    *   Create a `.env` file by copying the `.env.example`.
    *   Enter your MEXC API `Access Key` and `Secret Key`. Ensure the API key has permissions for futures trading.
    ```
    Bitget_ACCESS_KEY="bg_42d99891d38c33e19029d356a48d2a02"
    Bitget_SECRET_KEY="fd25ca3c3ea6af48b376fdb6cad418ef68feac38189fcfd2cf7bcd2685af6982"
    Bitget_PASSPHRASE="CryptoBlijvenKopen"
    ```
4.  **Run the application:**
    ```bash
    # Add command to run the main application script.
    python main.py
    ```

### **Development Status & Backtesting**

The project is in its initial development phase. The immediate focus is on validating the reliability and performance of the trade execution engine on the MEXC exchange.

Backtesting is ongoing, but users should be aware that backtesting results have inherent limitations and may not accurately reflect live market dynamics, such as slippage, fees, and API latency.

### **Future Roadmap**

*   Integration with regulated EU-based exchanges or alternatives.
*   Expansion to include spot trading strategies.
*   Refinement of AI analytical models for more sophisticated signal generation.
*   Development of a comprehensive performance analytics dashboard.

### **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.