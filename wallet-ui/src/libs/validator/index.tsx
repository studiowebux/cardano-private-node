import { Context } from "hono";
import { JSX } from "hono/jsx/jsx-runtime";
import { z, ZodFormattedError, ZodType } from "zod";

import { ErrorMessage } from "../../components/layouts/error.tsx";

export function validatorHandling<T extends ZodType>(
  result: any,
  c: Context
): z.TypeOf<T> | JSX.Element {
  console.debug("validatorHandling", result);
  if (!result.success) {
    console.error(result);
    c.res.headers.append("HX-Retarget", "#error");
    return c.html(
      <div hx-swap-oob="true" id="error">
        <ErrorMessage
          message={Object.entries(result.error.format())
            .filter(([key, _]) => key !== "_errors")
            .map(
              ([key, err]) =>
                `Field '${key}': ${(
                  err as ZodFormattedError<any>
                )._errors?.join(",")}`
            )
            .join(",")}
        />
      </div>,
      400
    );
  }

  return result.data;
}
