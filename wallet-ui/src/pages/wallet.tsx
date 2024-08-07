import type { FC } from "hono/jsx";

import { Layout } from "../components/layouts/layout.tsx";
import {
  show_addresses_for_wallet_id,
  show_assets_for_wallet_id,
  show_wallet,
} from "../api/index.tsx";

export const WalletPage: FC<{ wallet_id: string }> = async (props) => {
  return (
    <Layout>
      <main class="container">
        {await show_wallet(props.wallet_id)}

        <div>
          <h2>Sign transaction</h2>

          <form
            hx-post="/wallet/transaction-sign"
            hx-swap="innerHTML"
            hx-target="#signature"
          >
            <input type="hidden" name="encoding" value="base16" />
            <input type="hidden" name="wallet_id" value={props.wallet_id} />
            
            <label htmlFor="passphrase">Passphrase</label>
            <input type="password" name="passphrase" id="passphrase" />

            <label htmlFor="transaction">Transaction</label>
            <textarea
              name="transaction"
              id="transaction"
              cols="30"
              rows="10"
            ></textarea>

            <button>Sign</button>
          </form>

          <div>
            Signature:
            <div class="p-2" id="signature"></div>
          </div>
        </div>

        <div>
          <h2>Addresses</h2>
          {await show_addresses_for_wallet_id(props.wallet_id)}
        </div>

        <div>
          <h2>Assets</h2>
          {await show_assets_for_wallet_id(props.wallet_id)}
        </div>
      </main>
    </Layout>
  );
};
