# 💊 PumpFun EVM Smart Contract

The **Pump.fun EVM Smart Contract** brings the power of viral, one-click token creation to the **EVM-Compatible blockchain**, mirroring the simplicity and virality of the original **Pump.fun** on Solana. This version is built natively for **Monad's EVM-compatible testnet**, with full support for **Uniswap liquidity migration**, enabling instant tradability in the broader Ethereum ecosystem.

---

## ✨ Key Features

- **Token Creation**  
  Instantly create customizable tokens (name, symbol, total supply) on Monad.

- **Bonding Curve Pricing**  
  Implements a linear bonding curve for fair price discovery, rewarding early buyers.

- **Auto Liquidity Management**  
  Seamlessly manage buys/sells using an embedded bonding curve—no AMM setup required.

- **🔄 Uniswap Migration**  
  Once the liquidity threshold is hit, migrate liquidity to **Uniswap V2/V3** for open DeFi trading.

- **Full Onchain Execution**  
  All logic is executed onchain—including minting, pricing, and migration—for maximum transparency and decentralization.

- **EVM-Compatible**  
  Written in **Solidity**, deployed on Monad, and fully interoperable with Ethereum tooling like **Hardhat**, **Foundry**, and **MetaMask**.

---

## 🚀 Latest Enhancements

### 🔄 Uniswap Liquidity Migration  
After sufficient buy-in volume is reached, token liquidity is automatically migrated to a Uniswap pool—allowing users to continue trading in the open market with real-time pricing and increased exposure.

### ✅ Token Authority Options  
Smart contract logic supports optional authority revocation or time-bound admin permissions, ensuring flexibility in launch strategy (community-led or project-driven).

### 📊 Real-Time Metrics (Coming Soon)  
Planned dashboard support for token metrics, price charts, migration status, and market depth.

---

## 🧠 Technical Stack

- **Smart Contract Language:** Solidity  
- **Blockchain:** Monad (Testnet)  
- **DEX Integration:** Uniswap V2/V3  
- **Bundling Tools:** Jito-style bundling, MEV-optimized TX batching (optional)  
- **Dev Tools:** Hardhat, Foundry, Ethers.js

---

## 💻 Proof of Work

[Contract Address](https://testnet.monadexplorer.com/address/0x802Bbb3924BEE46831cadD23e9CfA9e74B499Efb)
- [Launch Token](https://testnet.monadexplorer.com/tx/0x44ce82f48eabc5e5f1be7bfb6414d380071a4993cd458b191d571568bb2c3190)
- [Buy Tx](https://testnet.monadexplorer.com/tx/0xaf91c0e9254248b27310652da1c1bdfbf7a40d88cf7c72b0fabbd76ce24ec160)
- [Sell Tx](https://testnet.monadexplorer.com/tx/0x3058ceca20593a1acff0e4c3534a92243ff554dc951f40e61a87476b75c29e9d)
- [Buy & Migration to Uniswap](https://testnet.monadexplorer.com/tx/0x1dd9da4ec6acab116cc2b4a24c97ff5e6a93a0fe5ce0c8413436a0489243cad2)

## ⚠️ Notes

- Currently deployed on **Monad Testnet**. Awaiting Monad mainnet release for production launch.
- Bonding curve mechanics mirror Solana Pump.fun’s pricing structure.
- Liquidity migration requires minimum bonding curve volume (configurable via contract params).

---

## 🤝 Credits

This project is inspired by the original [Pump.fun Solana Smart Contract](https://github.com/justshiftjk/Pump.fun-Smart-Contract), re-engineered for EVM chains starting with Monad.

---

## 📬 Contributing

PRs, issues, and feature suggestions are welcome! Feel free to fork, build, and contribute to the evolution of memecoin infrastructure on Monad.

---

## 📩 Contact  
For inquiries, custom integrations, or tailored solutions, reach out via:  

📧 **E-Mail**: [adamglab0731.pl@gmail.com](mailto:adamglab0731.pl@gmail.com)  
💬 **Telegram**: [@bettyjk_0915](https://t.me/bettyjk_0915)
