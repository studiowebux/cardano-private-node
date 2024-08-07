// Send transaction copied from Daogora project (2024-08-06)
import { Buffer } from "node:buffer";

// @ts-types="@emurgo/cardano-serialization-lib-nodejs/cardano_serialization_lib.d.ts"
import {
  Address,
  Value,
  TransactionOutput,
  BigNum,
  TransactionInput,
  TransactionHash,
  Transaction,
  TransactionWitnessSet,
  hash_transaction,
  make_vkey_witness,
  PrivateKey,
  Vkeywitnesses,
  TransactionBuilder,
  LinearFee,
  TransactionBuilderConfigBuilder,
} from "@emurgo/cardano-serialization-lib-nodejs";

import { Utxo, Tip } from "../types/blockfrost.types.ts";
import { ApiError } from "../libs/error.ts";
import { env } from "../libs/env.ts";

export const linearFee = LinearFee.new(
  BigNum.from_str("44"),
  BigNum.from_str("155381"),
);

export const txBuilderCfg = TransactionBuilderConfigBuilder.new()
  .fee_algo(linearFee)
  .pool_deposit(BigNum.from_str("500000000"))
  .key_deposit(BigNum.from_str("2000000"))
  .max_value_size(5000)
  .max_tx_size(16384)
  .coins_per_utxo_byte(BigNum.from_str("4310"))
  .build();

/**
 * Submit Transaction to network using the cardano-submit-api
 * The transaction must be a cbor hex (84...)
 * Official API Definition: https://input-output-hk.github.io/cardano-rest/submit-api/#operation/postTransaction
 * @param transaction cborHex
 * @returns transaction hash on success or an object with the error details
 */
export async function submit_api(
  transaction: string,
): Promise<string | object> {
  const res = await fetch(`${env.CARDANO_SUBMIT_API_BASE_URL}/api/submit/tx`, {
    method: "POST",
    body: Buffer.from(transaction, "hex"),
    headers: { "Content-Type": "application/cbor" },
  });
  console.log("Submit status", res.status);
  const json_data = await res.json();
  if (res.status < 200 || res.status > 299) {
    throw new ApiError(
      JSON.stringify(json_data, null, 2),
      "ERROR_SUBMIT_TX",
      res.status,
    );
  }
  return json_data;
}

/**
 * Get Address utcos from blockfrost
 */
export async function get_utxos_api(address: string): Promise<Utxo[]> {
  const res = await fetch(
    `${env.BLOCKFROST_BASE_URL}/addresses/${address}/utxos`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        project_id: env.BLOCKFROST_API_KEY,
      },
    },
  );

  return await res.json();
}

/**
 * Select Utco from the list returned by blockfrost endpoint
 */
export function select_utxo_api(utxos: Utxo[], amount: number | bigint): Utxo {
  const amount_to_compare: bigint =
    typeof amount === "bigint" ? amount : BigInt(amount);

  for (const utxo of utxos) {
    if (
      utxo.amount.some((asset) => BigInt(asset.quantity) > amount_to_compare)
    ) {
      return utxo;
    }
  }

  throw new ApiError(
    `Unable to locate a valid UTXO to cover the specified amount (${amount})`,
    "INSUFFICIENT_UTXO",
    422,
  );
}

/**
 * Using blockfrost api the get the tip of the chain
 */
export async function get_tip_api(): Promise<Tip> {
  const res = await fetch(`${env.BLOCKFROST_BASE_URL}/blocks/latest`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      project_id: env.BLOCKFROST_API_KEY,
    },
  });

  return await res.json();
}

export async function get_slot_api(): Promise<number> {
  const tip = await get_tip_api();
  return tip.slot;
}

export async function send_ada(
  address: string, // receiver
  lovelace_to_send: string,
  sender_sk: string,
  sender_address: string,
  ttl: number = 1_000,
) {
  const txBuilder = TransactionBuilder.new(txBuilderCfg);

  const pk = PrivateKey.from_normal_bytes(
    Uint8Array.from(Buffer.from(sender_sk, "hex")),
  );

  // UTXO to use to send ADA
  const utxo: Utxo = select_utxo_api(
    await get_utxos_api(sender_address),
    BigInt(lovelace_to_send),
  );

  const quantity = utxo.amount.find(
    (amount) => amount.unit === "lovelace",
  )?.quantity;
  if (!quantity) {
    throw new ApiError(
      "Unable to determine the amount of lovelace for the selected UTXO",
      "MISSING_LOVELACE_IN_UTXO",
      422,
    );
  }

  const input = TransactionInput.new(
    TransactionHash.from_hex(utxo.tx_hash),
    utxo.output_index,
  );

  txBuilder.add_key_input(
    pk.to_public().hash(),
    input,
    Value.new(BigNum.from_str(quantity)),
  );

  txBuilder.add_output(
    TransactionOutput.new(
      Address.from_bech32(address),
      Value.new(BigNum.from_str(lovelace_to_send)),
    ),
  );

  txBuilder.set_ttl((await get_slot_api()) + ttl);

  txBuilder.add_change_if_needed(Address.from_bech32(sender_address));

  const txBody = txBuilder.build();
  const txHash = hash_transaction(txBody);
  const witnesses = TransactionWitnessSet.new();

  // add keyhash witnesses
  const vkeyWitnesses = Vkeywitnesses.new();
  const vkeyWitness = make_vkey_witness(txHash, pk);
  vkeyWitnesses.add(vkeyWitness);
  witnesses.set_vkeys(vkeyWitnesses);

  const transaction = Transaction.new(
    txBody,
    witnesses,
    undefined, // transaction metadata
  );

  const response = await submit_api(transaction.to_hex());
  return response;
}
