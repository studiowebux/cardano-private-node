// deno run -A __tests__/test.0.ts

import { __connect_socat } from "../../server/src/libs/cardano/network/socat.ts";
import { send_ada } from "../src/api/index.tsx";

__connect_socat();

await send_ada(
  "addr_test1qppfhnkksq6l6ymq9qhaqtf8kgcqldnehtdsjxsfhz9s0ml79a83xsmmk36hwfe8vtgaypyjzkr3hmw6lfsscw84rtjqxa7ln7",
);

Deno.exit(0);
