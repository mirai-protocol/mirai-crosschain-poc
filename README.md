# mirai-crosschain-poc
POC contracts for cross chain deposits, withdraws, borrows and repays on mirai protocol.
# Contract addresses

- Goerli USDC: https://goerli.etherscan.io/address/0x07865c6E87B9F70255377e024ace6630C1Eaa37F#readProxyContract

- ESource: https://goerli.etherscan.io/address/0xf4bA4d42C0Cab995571e2fD044e48629F634518d

- DSource: https://goerli.etherscan.io/address/0x6459c5DD711b10524Ad77559793158ea5AcC980F

- Target: https://mumbai.polygonscan.com/address/0x4836966fa10A5DD930c9a4BcA62873b25757619d


## What is Mirai Protocol?

Mirai Protocol is a cross-chain lending protocol which is on the polygon testnet. Users are able to deposit from ethereum testnet to the protocol and even borrow funds from polygon testnet to the ethereum.

## Why Mirai Protocol?

FragFi is the problem where liquidity is distributed on different chains affecting capital efficiency. eg: Uniswap, AAVE on multiple chains.\
TVL is held on a single chain (polygon) and increases Capital Efficiency.

## How does Mirai Protocol work?

### Crosschain Lending

1.  The user wants to deposit 100 USDC from Ethereum to the Mirai Protocol on Polygon. They call the Deposit function on mUSDC sending 100 USDC.

2.  The USDC to be deposited (100 USDC) is sent to polygon using Connext Network

3.  The amount of USDC is received on polygon.

4.  A Smart Contract wallet is created for the user which is used for accounting purposes and the USDC is sent there.

5.  The 100 USDC is then deposited into Mirai Network and it mints mUSDC(interest bearing token) to the Smart Contract wallet and a notification using Push Protocol is sent to the user.

6.  The amount of mUSDC is then sent back to the ethereum using Connext Network.

7.  mUSDC is then minted on the ethereum chain and a notification in sent using Push Protocol.

### Cross-Chain Borrowing

1.  The user wants to borrow 50 DAI from Mirai Protocol on Polygon to ethereum. They call the borrow function on dDAI requesting 50 DAI.

2.  The amount of DAI to be borrowed is sent to the polygon network using Connext network

3.  The amount of DAI is then sent to the smart contract wallet and the dDAI(debt DAI) is minted into the smart contract wallet.

4.  The user receives a notification that the amount is borrowed on Polygon using Push Network.

5.  The amount of dDAI minted on Polygon is sent to connext network and then received on the Ethereum network.

6.  dDAI is then minted into the users wallet and a notification is sent to the user using push protocol.

### Cross-Chain Collateral Withdrawal

1.  The user wants to withdraw 100 USDC of his collateral from Mirai Protocol on Polygon to ethereum. They call the borrow withdraw function on mUSDC requesting 100 USDC.

2.  The amount of USDC to be returned is sent to the polygon network using Connext network.

3.  The amount of USDC is then sent to the smart contract wallet and the mUSDC(interest bearing USDC) is burned from the smart contract wallet.

4.  The user receives a notification that the amount is withdrawn on Polygon using Push Network.

5.  The amount of mUSDC burned on Polygon is sent to connext network and then received on the Ethereum network.

6.  mUSDC is then burned from the users wallet and a notification is sent to the user using push protocol.

### Cross-chain Loan Repay

1.  The user wants to repay 50 DAI from Ethereum to the Mirai Protocol on Polygon. They call the Repay function on dDAI sending 50 DAI.

2.  The DAI to be deposited (50 DAI) is sent to polygon using Connext Network

3.  The amount of DAI is received on polygon.

4.  The Smart Contract wallet which was created for the user which is used for accounting purposes and the DAI is sent there.

5.  The 50 DAI is then returned into Mirai Network and it burns dDAI(debt token) from the Smart Contract wallet and a notification using Push Protocol is sent to the user.

6.  The amount of dDAI is then sent back to the ethereum using Connext Network.

7.  dDAI is then burned on the ethereum chain from the users wallet and a notification is sent using Push Protocol.

## For Polygon Prize:

- Factory Contract to receive data from Goerli chain:

- Smart Contract deployed by factory contract:

- Contracts for Eular Fork: https://github.com/mirai-protocol/ethindia-lending-protocol

## For Connext Prize:

-   Take an existing protocol crosschain with Connext

-   We have taken Euler.Finance Cross-Chain.

-   You can now Lend, Borrow, Repay, Withdraw all from Goerli while interacting with Contracts on Mumbai

-   Best new cross chain use-case

-   We have create a DeFi lego compatible cross-chain lending.

-   Composable Cross-Chain Lending-When you deposit Cross-chain (goerli to mumbai) you receive mTokens (interest bearing tokens). We then in a Nested xcall sent the mTokens back to goerli which can further be used in other DeFi Projects.

-   Cross-Chain Borrowing-After depositing you can now borrow from goerli even though the protocol is in Mumbai. We use an xCall to request funds from Mumbai to goerli. We then send a nested xCall to send over funds from the protocol(mumbai) to the user(goerli) as well as minting him dTokens(Debt Tokens.)

-   Pool bounty for using xCall

-   To create Complete crosschain compatibility we have used 4 nested xCalls, 8 xCalls in total.

## For Push Prize:

We are using the Push Notification Service to alert the user when a Cross-Chain Deposit (Goerli to Mumabi) is done.\
Push protocol here is useful as it takes 2 mins for a crosschain call and users get notified of every step.

1.  We send a Push Notifcation once the Crosschain deposit is done. (Mumbai)

Code Line: https://github.com/mirai-protocol/mirai-crosschain-poc/blob/main/contracts/TargetNext.sol#L186

2.  We send a Push Notification once the interest bearing token is minted. (Goerli)

Code Line: https://goerli.etherscan.io/address/0xa19a9a51f04763f7bb0ac376346dcaae182b13de#code#F38#L186

(Image)

## For the Graph prize:

We have deployed a subgraph for the Eular Finance (lending protocol) on Mumbai.

Code: https://github.com/mirai-protocol/mirai-protocol-subgraphs

Subgraph: https://thegraph.com/hosted-service/subgraph/cryption-network/mirai-protocol
