import { Address, Asset, Wallet } from "../types/wallet.ts";
import { LIST_WALLETS, WALLET_BASE_URL } from "../constant.ts";

import { ErrorMessage } from "../components/layouts/error.tsx";

export async function show_wallet(wallet_id: string) {
  try {
    const response = await fetch(
      WALLET_BASE_URL + LIST_WALLETS + "/" + wallet_id,
    );

    if (response.ok) {
      const wallet: Wallet = await response.json();
      return (
        <article>
          <div>
            <div>
              <p class="text-lg">Wallet ID {wallet.id}</p>
            </div>
            <div class="grid">
              <div>
                <p class="text-lg">
                  Total balance: {wallet.balance.total.quantity} Lovelace (
                  {wallet.balance.total.quantity / 1_000_000}ADA)
                </p>
              </div>
              <div>
                <p class="text-lg">
                  Number of assets: {wallet.assets.total.length} Assets
                </p>
              </div>
            </div>
          </div>
        </article>
      );
    }
    const error = await response.json();
    throw new Error(error.message);
  } catch (e) {
    console.error(e);
    return <ErrorMessage message={e.message} />;
  }
}

export async function show_addresses_for_wallet_id(wallet_id: string) {
  try {
    const response = await fetch(
      WALLET_BASE_URL + LIST_WALLETS + "/" + wallet_id + "/addresses",
    );

    if (response.ok) {
      const addresses: Address[] = await response.json();
      return (
        <>
          {addresses.map((address) => (
            <article>
              <div>
                <div class="grid">
                  <div>
                    <p class="text-sm">{address.id}</p>
                  </div>
                  <div>
                    <p class="text-end text-lg">{address.state}</p>
                  </div>
                </div>
              </div>
            </article>
          ))}
        </>
      );
    }
    const error = await response.json();
    throw new Error(error.message);
  } catch (e) {
    console.error(e);
    return <ErrorMessage message={e.message} />;
  }
}

export async function show_assets_for_wallet_id(wallet_id: string) {
  try {
    const response = await fetch(
      WALLET_BASE_URL + LIST_WALLETS + "/" + wallet_id + "/assets",
    );

    if (response.ok) {
      const assets: Asset[] = await response.json();
      return (
        <>
          {assets.map((asset) => (
            <article>
              <div>
                <div class="grid">
                  <div>
                    <p class="text-sm">Policy id: {asset.policy_id}</p>
                    <p class="text-sm">Fingerprint: {asset.fingerprint}</p>
                  </div>
                  <div>
                    <p class="text-end text-lg">Asset Name{asset.asset_name}</p>
                  </div>
                  <div>
                    <pre>{JSON.stringify(asset.metadata)}</pre>
                  </div>
                </div>
              </div>
            </article>
          ))}
        </>
      );
    }
    const error = await response.json();
    throw new Error(error.message);
  } catch (e) {
    console.error(e);
    return <ErrorMessage message={e.message} />;
  }
}

export async function get_wallets() {
  try {
    const response = await fetch(WALLET_BASE_URL + LIST_WALLETS);

    if (response.ok) {
      const wallets: Wallet[] = await response.json();
      return (
        <article class="p-2">
          {wallets.map((wallet) => (
            <div>
              <div class="grid">
                <div>
                  <a class="text-lg" href={`/wallet/${wallet.id}`}>
                    {wallet.id}
                  </a>
                </div>
                <div>
                  <p class="text-end text-lg">
                    {wallet.balance.total.quantity} Lovelace
                  </p>
                </div>
                <div>
                  <p class="text-end text-lg">
                    {wallet.assets.total.length} Assets
                  </p>
                </div>
              </div>
            </div>
          ))}
        </article>
      );
    }
    const error = await response.json();
    throw new Error(error.message);
  } catch (e) {
    console.error(e);
    return <ErrorMessage message={e.message} />;
  }
}
