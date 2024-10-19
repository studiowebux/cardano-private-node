# Private cardano node + tools

This setup is a straightforward private Cardano cluster equipped with several tools for local development.
It also includes a basic UI that functions as a faucet for obtaining test funds.
Additionally, I tested and updated a fork of the NAMI wallet to ensure a working browser extension.

## Documentation

- [HOW TO](infrastructure-resources/HOW_TO.md)
- Youtube Video : https://youtu.be/BYICNUiORAE

## Components (Tested)

- Cardano node 9.2.1
- Ogmios v6.8.0
- Postgres 14.10
- DB Sync 13.5.0.2
- Submit API
- Blockfrost RYO v2.2.2

- Faucet-UI (maintained) - http://localhost:8002/
- Wallet-UI (Don't really need it anymore)
- token-registry it is a placeholder API for NAMI

- NAMI Fork: https://github.com/studiowebux/nami (You will have to change the IP to fit your setup, see bottom of the readme for the steps.)

## Blockfrost API Endpoints

- http://localhost:3010/blocks/latest
- http://localhost:3010/addresses/addr_test1qqx93zaarmlqwv5ptslvaclyxt3kke2296kpaf6vfkz87kyzgpt30akcklt630wjw4cqzc253k6ud63c5kh9jexldmvs0h7dq6/utxos
- http://localhost:3010/epochs/latest/parameters

## Contribution

- Feel free to open GitHub issues if you encounter any problems or have suggestions.
- I began working on this ~two~ few weeks ago, so it is still a work in progress.
- My primary focus has been on the components that I needed most, cardano node, Ogmios, submit api, blockfrost RYO and DB Sync.
