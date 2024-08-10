# Private cardano node + tools

This setup is a straightforward private Cardano cluster equipped with several tools for local development.
It also includes a basic UI that functions as a faucet for obtaining test funds.
Additionally, I tested and updated a fork of the NAMI wallet to ensure a working browser extension.

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

- NAMI Fork: https://github.com/studiowebux/nami (You will have to change the IP to fit your setup, see bottom of the readme for the steps.)

## Contribution

- Feel free to open GitHub issues if you encounter any problems or have suggestions.
- I began working on this ~two~ few weeks ago, so it is still a work in progress.
- My primary focus has been on the components that I needed most, cardano node, Ogmios, submit api, blockfrost RYO and DB Sync.
