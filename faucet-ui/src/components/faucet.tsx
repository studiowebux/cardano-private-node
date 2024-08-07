import type { FC } from "hono/jsx";

export const Faucet: FC = async () => {
  return (
    <div>
      <h2>Faucet</h2>

      <form hx-post="/faucet" hx-swap="innerHTML" hx-target="#response">
        <label htmlFor="address">Address</label>
        <input type="text" name="address" id="address" />
        <button type="submit">Get ADA</button>
      </form>

      <div id="response"></div>
    </div>
  );
};
