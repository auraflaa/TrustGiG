# TrustGig: The Architecture of Trustless Collaboration

TrustGig is a decentralized labor marketplace designed to eliminate the "middleman tax" and solve the systemic issues of the gig economy. By replacing corporate intermediaries with autonomous smart contracts, we return the ownership economy to the workers themselves.

## 🛠 Tech Stack & Distributive Architecture

Unlike traditional Web2 platforms that rely on a central database, TrustGig utilizes a modular, distributive stack to ensure censorship resistance and economic efficiency.

- **Blockchain Layer (Polygon)**: Built on Layer 2 scaling solutions to ensure low gas fees, preventing the adoption hurdles faced by early pioneers like Ethlance.
- **Payment Layer (Superfluid)**: Utilizes Money Streaming to solve the "Ghosting" problem. Funds flow every second (e.g., $0.00038/sec), allowing freelancers to be paid in real-time while they work.
- **Justice Layer (Kleros)**: Decentralized court system uses game theory (the Schelling Point) to adjudicate disputes. Jurors stake PNK tokens and are incentivized to converge on an honest verdict to avoid being slashed.
- **Identity Layer (Lens Protocol)**: Professional reputation stored as a portable NFT social graph. Prevents "platform lock-in" by allowing freelancers to take their 5-star ratings to any marketplace.
- **Privacy Layer (Semaphore)**: Leverages Zero-Knowledge Proofs (ZKPs) to allow users to prove expertise (e.g., "Verified Python Expert") without revealing their wallet balance or real identity.

## 🏗 System Design & Workflow

The prototype implements a deterministic state machine within the `TrustGigEscrow.sol` contract:

1. **Job Initialization**: Client deposits the full contract value (e.g., 1000 USDC) into the escrow contract, moving the state to `Locked`.
2. **Continuous Flow**: Superfluid stream opens. If the client becomes unresponsive, the freelancer stops working immediately, losing only seconds of labor rather than weeks.
3. **Proof of Work**: Freelancer submits evidence (e.g., GitHub commit hash) via `submitWork()`.
4. **Dispute Resolution**: `raiseDispute()` freezes remaining funds and triggers a Community Jury or Kleros court to review the on-chain history.

## 🚀 Prototype Features

- **Gas-less Onboarding**: Integrated with Account Abstraction (ERC-4337) for email logins and gas-free transactions for non-technical users.
- **Incentivized Arbitration**: "Staking for Justice" model where judges are compensated from the loser's staked assets, discouraging frivolous disputes.
- **Portable CV**: Live dashboard pulling decentralized social data to display verified work history across the Web3 ecosystem.

## 📂 Repository Contents

- `contracts/`: Core Solidity logic for Escrow and Jury mechanisms.
- `scripts/`: Deployment scripts for Polygon network.
- `tests/`: Hardhat tests verifying Happy Path and Dispute Path logic.
- `TrustGigEscrow.sol`: Primary smart contract governing trustless collaboration.

## 🧪 Live Remix Environment

You can open and experiment with the TrustGig smart contracts directly in Remix using the following link:

- **Remix IDE (Solidity 0.8.31, London EVM)**:  
  https://remix.ethereum.org/?#nomobileredirect&lang=en&optimize&runs=200&evmVersion=london&version=soljson-v0.8.31+commit.fd3a2265.js
