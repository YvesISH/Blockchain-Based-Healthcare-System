# Blockchain-Based Healthcare System  

## Overview  
This project is a decentralized healthcare system built on the Ethereum blockchain using Solidity and Hardhat. It allows secure and transparent doctor-patient interactions, including doctor registration, patient data retrieval, and electronic health record (EHR) management.

## Features  
- **Doctor Registration** – Doctors can register using their Ethereum address.  
- **Patient Records** – Patients' health data is securely stored and retrieved.  
- **Role-Based Access Control** – Only registered doctors can access patient records.  
- **Ethereum Smart Contracts** – Data is stored in an immutable and decentralized manner.  
- **Security & Transparency** – Utilizes Solidity smart contracts with access control.  

## 🛠 Tech Stack  
- **Solidity** – Smart contract development  
- **Hardhat** – Ethereum development and testing framework  
- **Ethers.js** – Interacting with the blockchain  
- **Node.js** – Backend integration  
- **React.js** (Optional) – Frontend for UI  
- **IPFS** (Optional) – Decentralized file storage  

## 📂 Project Structure  
```bash
📂 blockchain-healthcare
│── 📁 contracts             # Solidity smart contracts
│── 📁 scripts               # Deployment and interaction scripts
│── 📁 test                  # Test scripts for smart contracts
│
│── 📜 hardhat.config.js     # Hardhat configuration
│── 📜 package.json          # Node.js dependencies
│── 📜 README.md             # Project documentation


## 🔧 Installation  

### Clone the Repository  
```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/blockchain-healthcare.git 
cd blockchain-healthcare

### Install Dependencies
npm install

### Compile Smart Contracts
npx hardhat compile

### Run Tests
npx hardhat test

### Deploy to Local Blockchain
npx hardhat node

### Deploy contracts:
npx hardhat run scripts/deploy.js --network localhost