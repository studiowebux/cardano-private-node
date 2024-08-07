export type Wallet = {
  id: string;
  address_pool_gap: number;
  balance: {
    available: {
      quantity: number;
      unit: "lovelace";
    };
    reward: {
      quantity: number;
      unit: "lovelace";
    };
    total: {
      quantity: number;
      unit: "lovelace";
    };
  };
  assets: {
    available: { policy_id: string; asset_name: string; quantity: number }[];
    total: { policy_id: string; asset_name: string; quantity: number }[];
  };
  delegation: object; // TODO: Not used.
  name: string;
  passphrase: {
    last_updated_at: string;
  };
  state: {
    status: string;
  };
  tip: {
    absolute_slot_number: number;
    slot_number: number;
    epoch_number: number;
    time: string;
    height: { quantity: number; unit: "block" };
  };
};

export type Address = {
  id: string;
  state: "used" | "unused";
  derivation_path: string[];
};

export type Asset = {
  policy_id: string;
  asset_name: string;
  fingerprint: string;
  metadata: object;
  metadata_error: string
}