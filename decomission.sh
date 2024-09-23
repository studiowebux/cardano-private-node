#!/bin/bash

# Usage : sudo bash decomission.sh

docker compose down --remove-orphans
sudo rm -rf cluster/ kupo/ cluster/ appdata/ dbsync/cexplorer dbsync/postgres tmp/ wallet-db/ blockfrost-backend-ryo/
