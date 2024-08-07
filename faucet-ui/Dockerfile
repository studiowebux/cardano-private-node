# docker build -t private-faucet-ui .
# docker run -it --rm --name faucet-ui --env-file .env -p 8002:8002 private-faucet-ui
FROM denoland/deno:1.45.5

# The port that your application listens to.
EXPOSE 8002

WORKDIR /app

# Prefer not to run as root.
USER deno

# These steps will be re-run upon each file change in your working directory:
COPY . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache src/bin/main.tsx

CMD ["task", "start"]
