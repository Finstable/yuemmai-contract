<p align="center">
  <a href="http://yestoken.digital/" target="_blank"><img src="assets/yes-logo.png" width="120" alt="YES Logo" /></a>
</p>

<p align="center">The first Decentralized Lending Platform in Bitkub Chain powered by Finstable.</p><p align="center">

## Description
This repository contains the source code for YES token lending smart contract written in Solidity. The project is a fork of Compound Finance V2. We modified the contract to support credit scoring mechanism and Bitkub Next wallet integration. In this version, only YES token can be used as a collateral.

## Prerequisites
1. Node JS version >=12
2. NPM version >=6

Note: Please use NVM to downgrade Node and NPM version for convinient.

## Installation
1. Clone this repository
2. Run `npm i` to download dependencies

## Setup
1. Copy `.env.example` and rename to `.env` and fill in your private keys.

## Commands
1. Unit testing: `npx hardhat test`.
2. ABI and typechain generating: `npx hardhat compile`.
3. Contract interaction: `npx hardhat run script scripts/<path-to-file> --network <network>`. Replace <path-to-file> with the folder and file name to run and replace <network> with the network name (see the available networks in `hardhat.config.ts` file).
4. Contract deployment: `npx hardhat run script deploy/<path-to-file> --network <network>`. Replace <path-to-file> and <network> in the same way as the previous command.

## Related repositories
This project contains with many pieces. Please find the source codes of those parts as follows:
1. <a href="https://github.com/Finstable/yes-frontend" target="_blank">Frontend</a> - The main user interface for interacting with lending contracts and campaigns by YES.
2. <a href="https://github.com/Finstable/yes-main-service" target="_blank">API Server</a> - Managing user accounts, credit scoring, campaigns, and token airdrops.
3. <a href="https://github.com/Finstable/yes-v2-contract" target="_blank">Contract V2</a> - Token lending contract with any collateralized tokens.
4. <a href="https://github.com/Finstable/wirtual-x-yes-contract" target="_blank">Wirtual NFT</a> - The token locking and NFT minting contract used in Wirtual campaign.
5. <a href="https://github.com/Finstable/yes-price-service" target="_blank">Price service</a> - YES token price needs to be updated regularly. This API server submits a transaction to record price snapshot on-chain for every preconfigured interval. The updated price is very important to lending functionality. Failing to update price will halt the lending/borrowing functions of the system.
6. <a href="https://github.com/Finstable/yes-v1-liquidate-service" target="_blank">V1 Liquidation service</a> - An example source code for liquidation bot. This service is used to trigger liquidation in the system. The bot receives some rewards as an incentives. There is no restriction on running the bot. It can be run by anyone with any kind of implementation. Just need to trigger the right function under the right conditions specified in the lending contract.
7. <a href="https://github.com/Finstable/yuemmai_v2_liquidation_bot_nest" target="_blank">V2 Liquidation service</a> - Same as the above code but is used for V2 contract.
