import type { FC } from "hono/jsx";

export const ErrorMessage: FC<{ message: string }> = (props) => {
  return (
    <dialog open id="error_message_popup">
      <article>
        <header>
          <button aria-label="Close" rel="prev" 
          onclick="deleteElementById('error_message_popup')"></button>
          <p>
            <strong>Error</strong>
          </p>
        </header>
        <p>{props.message}</p>
      </article>
    </dialog>
  );
};
