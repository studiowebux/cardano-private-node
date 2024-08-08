# Private cardano node + tools

This is a simple private cardano node with a couple of tools to develop locally.
Also a small UI to act as a faucet to get funds to test.

## Documentation

- [HOW TO](infrastructure-resources/HOW_TO.md)
- Youtube Video : https://youtu.be/BYICNUiORAE

## Components (Tested)

- Cardano node 9.1.0 (Conway era)
- Ogmios v6.5.0
- Kupo v2.9.0
- Postgres 14.10
- DB Sync 12.3.0.0 (and 13.2.0.2)
- Cardano Wallet 2024.7.19 (the wallet-ui is to interface with this, didn't test after setting up NAMI)
- Submit API
- Blockfrost RYO v2.1.0

- Faucet-UI (maintained)
- Wallet-UI (Don't really need it anymore)
- token-registry it is a placeholder API for NAMI

- NAMI Fork: https://github.com/studiowebux/nami (You will have to change the IP to fit your setup)

## Contribution

- Feel free to open GitHub issues if you encounter any problems or have suggestions.
- I began working on this two weeks ago, so it is still a work in progress. My primary focus has been on the components that I needed most.
