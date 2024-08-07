import type { FC } from "hono/jsx";

import { get_wallets } from "../api/index.tsx";

export const Wallets: FC = async () => {
  return <>{await get_wallets()}</>;
};
