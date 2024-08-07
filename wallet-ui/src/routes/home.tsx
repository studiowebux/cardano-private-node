import { Context, Hono } from "hono";
import { HomePage } from "../pages/home.tsx";

const app = new Hono();

app.get("/", (c: Context) => {
  return c.html(<HomePage />);
});

export default app;
