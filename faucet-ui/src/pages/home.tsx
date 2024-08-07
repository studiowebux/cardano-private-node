import type { FC } from "hono/jsx";

import { Layout } from "../components/layouts/layout.tsx";
import { Faucet } from "../components/faucet.tsx";

export const HomePage: FC = () => {
  return (
    <Layout>
      <main class="container">
        <h1>Faucet UI</h1>

        <Faucet />
      </main>
    </Layout>
  );
};
