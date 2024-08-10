# Start the stack

```bash
cd /opt/local-private-cardano

git clone https://github.com/studiowebux/cardano-private-node.git

chmod 0600 -R infrastructure-resources/dbsync/config/

docker compose build
cp faucet-ui/.env.example faucet-ui/.env
# The first time it will fail, this is expected.
docker compose up -d
# Running this command right after it showes failed to start, will setup the required files.
docker exec -it -w /app/cardano-node/ launcher bash -c "./scripts/babbage/mkfiles.sh"
# You have more or less 30 seconds to restart the cluster.
docker compose up -d
# Everything should show as UP
docker compose ps -a

# After few seconds this command will show that the chain is synced.
docker exec -it launcher bash -c "cardano-cli query tip --testnet-magic 42"

# This one the first time will either get stuck or take a very very very long time.
# DBSync can block the whole thing, as it is a test environemtn I simply restart it to skip the indexes (See youtube video for what it does.)
docker compose logs cardano-db-sync postgres -f
docker compose stats
# You can skip the indexes. Doesn't work everytime the command is ran...
docker compose restart cardano-db-sync
```

# Using your favorite SQL IDE

```bash
docker compose run -it postgres psql -d cexplorer -h postgres -U postgres
```

These commands are provided by blockfrost-RYO:

```sql
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
```

# Get the Address and SKEY for the faucet

launch the bootstrap.sh commands

```bash
# Open a console in the launcher container
docker exec -it -w /app/cardano-node/ launcher bash

# Launch the following commands to setup the faucet-ui:

# 1. Check if the cluster is up and running
cardano-cli query tip --testnet-magic 42

# Get the Addresses for each keys created by mkfiles.sh
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

# Print UTxOs
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo1.addr) --testnet-magic 42
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo2.addr) --testnet-magic 42
cardano-cli query utxo --address $(cat /app/appdata/wallets/utxo3.addr) --testnet-magic 42
```

These two commands print the necessary information to setup the faucet UI, we use the `utxo1.addr` to send ADA.

```bash
cat /app/appdata/wallets/utxo1.addr
cat /app/cardano-node/example/utxo-keys/utxo1.skey
```

copy the `skey` and `addr` in the faucet-ui `.env` file
```.env
NODE_ENV=production
# cat /app/appdata/wallets/utxo1.addr
GENESIS_ADDRESS=
# cat /app/cardano-node/example/utxo-keys/utxo1.skey (minus the first 4 chars)
GENESIS_PRIVATE_KEY=
```

docker compose up -d

---

# Destroy the stack

```bash
docker compose down --remove-orpans
sudo rm -rf cluster/ kupo/ cluster/ appdata/ dbsync/cexplorer dbsync/postgres tmp/ wallet-db/ blockfrost-backend-ryo/
```
