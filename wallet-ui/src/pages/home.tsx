import type { FC } from "hono/jsx";

import { Layout } from "../components/layouts/layout.tsx";
import { Wallets } from "../components/wallets.tsx";

export const HomePage: FC = () => {
  return (
    <Layout>
      <main class="container">
        <h1>Wallet UI</h1>

        <Wallets />
      </main>

      <footer>
      <p class="text-sm">Reference for Cardano Wallet (API): https://cardano-foundation.github.io/cardano-wallet/api/edge/</p>
      </footer>
    </Layout>
  );
};
