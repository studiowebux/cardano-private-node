#!/bin/bash

# Usage : sudo bash bootstrap.sh

set -e

# Change permissions of files in the infrastructure-resources/dbsync/config/ directory.
# This makes sure that only the owner can read, write, and execute these files.
chmod 0600 -R infrastructure-resources/dbsync/config/

# Build the Docker images defined in the docker-compose.yml file.
docker compose build

# Copy an example .env file to the faucet-ui directory. This file will be used by the faucet-ui container.
cp faucet-ui/.env.example faucet-ui/.env

# Start the containers defined in the docker-compose.yml file in detached mode (in the background).
docker compose up -d || docker exec -it -w /app/cardano-node/ launcher bash -c "./scripts/babbage/mkfiles.sh"

# Start the Docker containers again. This is because some services might not be ready after the first start command.
docker compose up -d
docker compose ps -a

# Check if the cluster is running by querying the tip of the blockchain using cardano-cli.
max_retries=5 # The script will try 5 times before giving up.
delay=10 # If a retry is needed, it will wait for 10 seconds.
for ((i=1; i<=max_retries; i++)); do
    if docker exec -it launcher bash -c "cardano-cli query tip --testnet-magic 42"; then
        break;
    else
        echo "Command failed. Attempt $i of $max_retries."
        if (( i < max_retries )); then
            echo "Retrying in $delay seconds..."
            sleep $delay
        else
            echo "Failed to validate that the cluster is running."
        fi
    fi
done

# Stop the cardano-db-sync container. We'll restart it later after creating some necessary indexes.
docker compose stop cardano-db-sync

# Create some indexes in the PostgreSQL database used by cardano-db-sync.
docker compose run -it --rm postgres psql "postgresql://postgres:example@postgres/cexplorer" -c "
CREATE INDEX IF NOT EXISTS bf_idx_block_hash_encoded ON block USING HASH (encode(hash, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_datum_hash ON datum USING HASH (encode(hash, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_multi_asset_policy ON multi_asset USING HASH (encode(policy, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_multi_asset_policy_name ON multi_asset USING HASH ((encode(policy, 'hex') || encode(name, 'hex')));
CREATE INDEX IF NOT EXISTS bf_idx_pool_hash_view ON pool_hash USING HASH (view);
CREATE INDEX IF NOT EXISTS bf_idx_redeemer_data_hash ON redeemer_data USING HASH (encode(hash, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_scripts_hash ON script USING HASH (encode(hash, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_tx_hash ON tx USING HASH (encode(hash, 'hex'));
CREATE UNIQUE INDEX IF NOT EXISTS bf_u_idx_epoch_stake_epoch_and_id ON epoch_stake (epoch_no, id);
CREATE INDEX IF NOT EXISTS bf_idx_reference_tx_in_tx_in_id ON reference_tx_in (tx_in_id);
CREATE INDEX IF NOT EXISTS bf_idx_collateral_tx_in_tx_in_id ON collateral_tx_in (tx_in_id);
CREATE INDEX IF NOT EXISTS bf_idx_redeemer_script_hash ON redeemer USING HASH (encode(script_hash, 'hex'));
CREATE INDEX IF NOT EXISTS bf_idx_redeemer_tx_id ON redeemer USING btree (tx_id);
CREATE INDEX IF NOT EXISTS bf_idx_col_tx_out ON collateral_tx_out USING btree (tx_id);
CREATE INDEX IF NOT EXISTS bf_idx_ma_tx_mint_ident ON ma_tx_mint USING btree (ident);
CREATE INDEX IF NOT EXISTS bf_idx_ma_tx_out_ident ON ma_tx_out USING btree (ident);
CREATE INDEX IF NOT EXISTS bf_idx_reward_rest_addr_id ON reward_rest USING btree (addr_id);
CREATE INDEX IF NOT EXISTS bf_idx_reward_rest_spendable_epoch ON reward_rest USING btree (spendable_epoch);
"

# Start the cardano-db-sync container again.
docker compose start cardano-db-sync

# In the launcher container, create some wallets and query their UTXO (unspent transaction outputs).
docker exec -it -w /app/cardano-node/ launcher bash -c "
cardano-cli query tip --testnet-magic 42

mkdir -p /app/appdata/wallets/

cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo1.vkey \
--out-file /app/appdata/wallets/utxo1.addr \
--testnet-magic 42

cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo2.vkey \
--out-file /app/appdata/wallets/utxo2.addr \
--testnet-magic 42

cardano-cli address build \
--payment-verification-key-file /app/cardano-node/example/utxo-keys/utxo3.vkey \
--out-file /app/appdata/wallets/utxo3.addr \
--testnet-magic 42

cardano-cli query utxo --address \$(cat /app/appdata/wallets/utxo1.addr) --testnet-magic 42
cardano-cli query utxo --address \$(cat /app/appdata/wallets/utxo2.addr) --testnet-magic 42
cardano-cli query utxo --address \$(cat /app/appdata/wallets/utxo3.addr) --testnet-magic 42
"

# Get the address and private key of one of the created wallets.
address=$(sudo cat ./appdata/wallets/utxo1.addr)
skey=$(sudo cat ./cluster/utxo-keys/utxo1.skey | jq -r '.cborHex[4:]')

# Update the .env file in the faucet-ui directory with the obtained address and private key.
sed -i faucet-ui/.env -e 's/NODE_ENV=development/NODE_ENV=production/'
sed -i faucet-ui/.env -e "s/GENESIS_ADDRESS=.*/GENESIS_ADDRESS=${address}/"
sed -i faucet-ui/.env -e "s/GENESIS_PRIVATE_KEY=.*/GENESIS_PRIVATE_KEY=${skey}/"

# Start the Docker containers again.
docker compose up -d

echo "* You might have to restart (yes again) the DB Sync container as it hangs the Postgres DB while doing indexes (that we wont use)"
docker compose restart cardano-db-sync

echo "Voila !"
