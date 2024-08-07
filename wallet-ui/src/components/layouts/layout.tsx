import type { FC } from "hono/jsx";

export const Layout: FC = (props) => {
  return (
    <html>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <script src="/public/htmx.min.js" />
        <link rel="stylesheet" href="/public/css/pico.yellow.min.css" />
        <link rel="stylesheet" href="/public/css/dark.min.css" />
        <link rel="stylesheet" href="/public/css/styles.css" />
        <meta name="description" content="Cardano Wallet UI" />
        <title>Wallet UI</title>
      </head>
      <body hx-ext="response-targets">
        <div id="error"></div>

        <div id="app">{props.children}</div>

        <script src="/public/modal.js" />
        <script src="/public/response-targets.js" />
        <script src="/public/app.js" />
      </body>
    </html>
  );
};
