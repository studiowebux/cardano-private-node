#!/bin/bash

# Usage : sudo bash bootstrap.sh

set -e

chmod 0600 -R infrastructure-resources/dbsync/config/

docker compose build

cp faucet-ui/.env.example faucet-ui/.env

docker compose up -d || docker exec -it -w /app/cardano-node/ launcher bash -c "./scripts/babbage/mkfiles.sh"

docker compose up -d
docker compose ps -a


max_retries=5 # Should take 3 attempts
delay=10
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

docker compose stop cardano-db-sync

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

docker compose start cardano-db-sync

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

address=$(sudo cat ./appdata/wallets/utxo1.addr)
skey=$(sudo cat ./cluster/utxo-keys/utxo1.skey | jq -r '.cborHex[4:]')
sed -i faucet-ui/.env -e 's/NODE_ENV=development/NODE_ENV=production/'
sed -i faucet-ui/.env -e "s/GENESIS_ADDRESS=.*/GENESIS_ADDRESS=${address}/"
sed -i faucet-ui/.env -e "s/GENESIS_PRIVATE_KEY=.*/GENESIS_PRIVATE_KEY=${skey}/"

docker compose up -d

echo "* You might have to restart (yes again) the DB Sync container as it hangs the Postgres DB while doing indexes (that we wont use)"
docker compose restart cardano-db-sync

echo "Voila !"
