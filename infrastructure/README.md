# Private Cardano node cluster

```bash
docker compose build
docker compose up
docker exec -it -w /app/cardano-node/ launcher bash -c "./scripts/babbage/mkfiles.sh"
```

```bash
docker compose up -d
docker compose logs --tail 100 -f
```

```bash
docker exec -it launcher bash

# Wait few seconds then it should work and show as below,
export CARDANO_NODE_SOCKET_PATH=/app/cardano-node/example/node-spo1/node.sock
cardano-cli query tip --testnet-magic 42
```

Launch commands from the `bootstrap.sh` and update values has needed.

Reference: https://webuxlab.com/en/devops/cardano-private-cluster

```bash
docker compose stop
docker compose rm
# FULL WIPE
sudo rm -rf cluster/ kupo/ docker-compose.yml Dockerfile dbsync/ cluster/ appdata/ tmp/
# Not full
sudo rm -rf cluster/ kupo/ cluster/ appdata/ dbsync/cexplorer dbsync/postgres tmp/
```

```bash
sudo socat TCP-LISTEN:1234,fork,reuseaddr UNIX-CONNECT:./cluster/main.sock
```

Follow this repo to get a working nami wallet extension: https://github.com/studiowebux/nami.git

---

# DB Sync setup

```bash
sudo vi dbsync/config/pg_passwd

# add this line
postgres:5432:cexplorer:postgres:example

sudo chmod 0600 dbsync/config/pg_passwd
```

# TODO

need to document step-by-step and probably make a video to show how "simple" it is.
