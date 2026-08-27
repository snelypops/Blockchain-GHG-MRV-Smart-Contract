# Blockchain-Based GHG Emissions MRV Smart Contract

A blockchain-based Monitoring, Reporting and Verification (MRV) solution for maintaining transparent, tamper-resistant and auditable greenhouse gas (GHG) emissions records for a manufacturing company.

## Overview

This project implements a Solidity smart contract, `MRVContract`, for recording and verifying GHG emissions reports.

The proposed production architecture uses a permissioned consortium blockchain with Proof-of-Authority (PoA) consensus. The prototype is deployed locally using Hardhat.

To protect commercially sensitive information, raw sensor data and complete emissions reports are stored off-chain. The blockchain stores the report's `keccak256` hash together with essential metadata, providing a tamper-evident record that can be independently verified.

## System Workflow

The system uses wallet-based roles:

- **Administrator** – registers facilities and manages user permissions.
- **Reporter** – submits emissions report hashes.
- **Auditor** – retrieves emissions records for verification.
- **Regulator** – accesses relevant records through the consortium network.

The workflow is:

1. The administrator registers a manufacturing facility.
2. The administrator authorises reporter and auditor wallets.
3. The authorised reporter submits an emissions report hash.
4. `MRVContract` records the hash, facility ID, reporting period, timestamp and submitting address.
5. The authorised auditor retrieves the record for verification.

## Smart Contract

The `MRVContract` provides:

- Facility registration and status management
- Reporter authorisation and revocation
- Auditor authorisation and revocation
- Emissions report submission
- Emissions record retrieval
- Role-based access control
- Event logging
- Append-only emissions records

Once an emissions record is submitted, the contract provides no function to modify or delete it.

## Web Interface

A web interface was developed to demonstrate interaction with the smart contract through MetaMask.

The interface allows users to:

- Connect a MetaMask wallet
- Register facilities
- Authorise reporters
- Authorise auditors
- Submit emissions report hashes
- Retrieve emissions records

The interface connects to the locally deployed smart contract and uses MetaMask to sign transactions.

## Technologies

- Solidity 0.8.36
- Hardhat 3
- Ethers.js
- Hardhat Ethers
- MetaMask
- HTML, CSS and JavaScript
- Ethereum-compatible blockchain

## Project Structure

```text
Blockchain-GHG-MRV-Smart-Contract/
│
├── contracts/
│   └── MRVContract.sol
│
├── script/
│   └── deploy.ts
│
├── index.html
├── hardhat.config.ts
├── package.json
└── package-lock.json