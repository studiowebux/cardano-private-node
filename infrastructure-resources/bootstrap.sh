#!/bin/bash

# MUST BE UPDATED TO FIT YOUR NEEDS
# RUN ALL THIS TO initialize the first wallet with 100ADA if all this works, you can continue.

docker exec -it launcher bash
export CARDANO_NODE_SOCKET_PATH=/app/cardano-node/example/node-spo1/node.sock
cardano-cli query tip --testnet-magic 42

cardano-cli signing-key-address \
    --testnet-magic 42 \
    --secret /app/cardano-node/example/byron-gen-command/genesis-keys.000.key > /app/cardano-node/example/byron-gen-command/genesis-keys.000.addr

cardano-cli signing-key-address \
    --testnet-magic 42 \
    --secret /app/cardano-node/example/byron-gen-command/genesis-keys.001.key > /app/cardano-node/example/byron-gen-command/genesis-keys.001.addr

cardano-cli signing-key-address \
    --testnet-magic 42 \
    --secret /app/cardano-node/example/byron-gen-command/genesis-keys.002.key > /app/cardano-node/example/byron-gen-command/genesis-keys.002.addr

mkdir -p /app/appdata/wallets/


cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo1.vkey \
--out-file /app/appdata/wallets/utxo1.addr \
--testnet-magic 42
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo1.addr) --testnet-magic 42

cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo2.vkey \
--out-file /app/appdata/wallets/utxo2.addr \
--testnet-magic 42
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo2.addr) --testnet-magic 42

cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo3.vkey \
--out-file /app/appdata/wallets/utxo3.addr \
--testnet-magic 42
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo3.addr) --testnet-magic 42

cardano-cli query protocol-parameters \
    --testnet-magic 42 \
    --out-file protocol.json

# Print the UTXOs from the utxo1 address,
# you need this value in order to create and send lovelace
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo1.addr) --testnet-magic 42
