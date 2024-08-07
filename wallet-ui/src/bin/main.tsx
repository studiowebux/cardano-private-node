import { Context, Hono } from "hono";
import { serveStatic } from "hono/deno";

import home from "../routes/home.tsx";
import wallet from "../routes/wallet.tsx";

import { ErrorMessage } from "../components/layouts/error.tsx";

const app = new Hono();

app.use("/public/*", serveStatic({ root: "./" }));

app.route("/", home);
app.route("/wallet", wallet);

app.onError((err: Error, c: Context) => {
  console.error("GLOBAL ERROR HANDLING", err);
  c.res.headers.append("HX-Retarget", "#error");
  return c.html(
    <div hx-swap-oob="true" id="error">
      <ErrorMessage message={err.message} />
    </div>,
    500,
  );
});

Deno.serve({ port: 8001, hostname: "0.0.0.0" }, app.fetch);
