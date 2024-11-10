# docker build -t cardano-private --progress=plain .
FROM ubuntu:22.04

WORKDIR /app

RUN apt update && apt install curl git jq xxd vim xz-utils unzip conntrack net-tools -y

RUN curl -OL https://github.com/IntersectMBO/cardano-node/releases/download/10.1.2/cardano-node-10.1.2-linux.tar.gz && \
    tar xvzf cardano-node-10.1.2-linux.tar.gz && \
    rm -f cardano-node-10.1.2-linux.tar.gz

RUN ln -s /app/bin/cardano-cli /usr/local/bin/cardano-cli && \
    ln -s /app/bin/cardano-node /usr/local/bin/cardano-node

RUN git clone https://github.com/IntersectMBO/cardano-node.git && \
    cd cardano-node && \
    git checkout 10.1.2

# debug: docker run -it --entrypoint /bin/bash --rm cardano-private-node-launcher
RUN sed -i 's/$CARDANO_CLI genesis create-staked/cardano-cli latest genesis create-staked/' cardano-node/scripts/babbage/mkfiles.sh

# # Trying to support Dolos. (2024-11-10, unable to support it as the configuration generated are too much different)
# # invalid type: floating point `0.1`, expected u32 at line 55 column 20
# RUN sed -i 's/slotLength:0.1/slotLength:1/' cardano-node/scripts/babbage/mkfiles.sh
# # invalid type: integer `13333333334`, expected a string at line 19 column
# RUN echo "jq '.initialFunds = (.initialFunds | to_entries | map(.value |= tostring) | from_entries)' ./example/genesis/shelley/genesis.json > ./example/genesis/shelley/genesis.json.tmp && mv ./example/genesis/shelley/genesis.json.tmp ./example/genesis/shelley/genesis.dolos.json" >> cardano-node/scripts/babbage/mkfiles.sh
# # invalid type: map, expected a string at line 59 column 67 (Dolos)
# RUN echo "jq 'del(.staking)' ./example/genesis/shelley/genesis.dolos.json > ./example/genesis/shelley/genesis.json.tmp && mv ./example/genesis/shelley/genesis.json.tmp ./example/genesis/shelley/genesis.dolos.json" >> cardano-node/scripts/babbage/mkfiles.sh
# # invalid type: sequence, expected a map at line 4 column 21
# RUN echo "" >> cardano-node/scripts/babbage/mkfiles.sh

# Generate Correct Hashes
RUN echo 'byronGenesisHash=$(cardano-cli byron genesis print-genesis-hash --genesis-json ./example/genesis/byron/genesis.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ByronGenesisHash: $byronGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

RUN echo 'alonzoGenesisHash=$(cardano-cli latest genesis hash --genesis ./example/genesis/shelley/genesis.alonzo.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "AlonzoGenesisHash: $alonzoGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

RUN echo 'conwayGenesisHash=$(cardano-cli latest genesis hash --genesis ./example/genesis/shelley/genesis.conway.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ConwayGenesisHash: $conwayGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

# Fix timestamp format
RUN echo 'START_TIME_UTC=$(${DATE} -d @$(cat ./example/genesis/byron/genesis.json | jq .startTime) --utc +%FT%TZ) && sed -i ./example/genesis/shelley/genesis.json -e "s/  \"systemStart\": \".*Z\"/  \"systemStart\": \"${START_TIME_UTC}\"/"' >> cardano-node/scripts/babbage/mkfiles.sh
RUN echo 'shelleyGenesisHash=$(cardano-cli latest genesis hash --genesis ./example/genesis/shelley/genesis.json)'>> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ShelleyGenesisHash: $shelleyGenesisHash" >> ./example/configuration.yaml'>> cardano-node/scripts/babbage/mkfiles.sh

# https://cardano-foundation.github.io/cardano-wallet/user
# https://cardano-foundation.github.io/cardano-wallet/api/edge/
RUN curl -OL https://github.com/cardano-foundation/cardano-wallet/releases/download/v2024-09-29/cardano-wallet-v2024-09-29-linux64.tar.gz && \
    tar xvzf cardano-wallet-v2024-09-29-linux64.tar.gz && \
    rm -rf cardano-wallet-v2024-09-29-linux64.tar.gz

RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

CMD ["sleep", "infinity"]
