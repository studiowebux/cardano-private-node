import { Context, Hono } from "hono";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";

import { WalletPage } from "../pages/wallet.tsx";
import { validatorHandling } from "../libs/validator/index.tsx";
import { LIST_WALLETS, WALLET_BASE_URL } from "../constant.ts";
import { ErrorMessage } from "../components/layouts/error.tsx";

const app = new Hono();

const schema = z.object({
  passphrase: z.string(),
  transaction: z.string(),
  wallet_id: z.string(),
  encoding: z.string(),
});

app.get("/:wallet_id", (c: Context) => {
  const wallet_id = c.req.param("wallet_id");
  return c.html(<WalletPage wallet_id={wallet_id} />);
});

app.post(
  "/transaction-sign",
  zValidator("form", schema, validatorHandling),
  async (c: Context) => {
    const { passphrase, transaction, wallet_id, encoding } = c.req.valid(
      "form"
    ) as z.infer<typeof schema>;

    const response = await fetch(
      WALLET_BASE_URL + LIST_WALLETS + "/" + wallet_id + "/transactions-sign",
      {
        method: "POST",
        body: JSON.stringify({
          encoding,
          passphrase,
          transaction,
        }),
        headers: {
          "Content-Type": "application/json",
        },
      }
    );

    const data = await response.json();
    if (data.transaction) {
      console.log(data.transaction)
      return c.html(data.transaction);
    }
    return c.html(
      <ErrorMessage message={`Unable to sign the transaction: ${data.message}`} />
    );
  }
);

export default app;
