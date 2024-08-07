import { load } from "dotenv";

type Env = {
  NODE_ENV: "development" | "production";
  // Faucet address
  GENESIS_ADDRESS: string;
  GENESIS_PRIVATE_KEY: string;
  // Cardano Shared libs
  CARDANO_SUBMIT_API_BASE_URL: string;
  BLOCKFROST_BASE_URL: string;
  BLOCKFROST_API_KEY: string;
};
export const env: Env = (await load()) as Env;
