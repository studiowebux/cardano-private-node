```bash
docker run --rm \
  --name blockfrost-ryo \
  -p 3000:3000 \
  -e BLOCKFROST_CONFIG_SERVER_LISTEN_ADDRESS=0.0.0.0 \
  -v $PWD/config:/app/config \
  blockfrost/backend-ryo:latest
```

Metadata server: https://input-output-hk.github.io/offchain-metadata-tools/#running-your-own-metadata-system


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
