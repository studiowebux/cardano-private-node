import { Context, Hono } from "hono";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";

import { HomePage } from "../pages/home.tsx";
import { validatorHandling } from "../libs/validator/index.tsx";
import { env } from "../libs/env.ts";
import { LOVELACE_TO_SEND, TTL } from "../constant.ts";

import { send_ada } from "../csl/index.ts";

const app = new Hono();

const schema = z.object({
  address: z.string(),
});

app.get("/", (c: Context) => {
  return c.html(<HomePage />);
});

app.post(
  "/faucet",
  zValidator("form", schema, validatorHandling),
  async (c: any) => {
    const { address } = c.req.valid("form") as z.infer<typeof schema>;

    const response = await send_ada(
      address,
      LOVELACE_TO_SEND,
      env.GENESIS_PRIVATE_KEY,
      env.GENESIS_ADDRESS,
      TTL,
    );

    if (typeof response === "object") {
      return c.html(response);
    }

    return c.html(
      <div>
        <p>Transaction submitted !</p>
        <p class="text-sm">{response}</p>
      </div>,
    );
  },
);

export default app;
