# docker build -t cardano-private --progress=plain .
FROM ubuntu:22.04

WORKDIR /app

RUN apt update && apt install curl git jq xxd vim xz-utils unzip conntrack net-tools -y

RUN curl -OL https://github.com/IntersectMBO/cardano-node/releases/download/9.2.1/cardano-node-9.2.1-linux.tar.gz && \
    tar xvzf cardano-node-9.2.1-linux.tar.gz && \
    rm -f cardano-node-9.2.1-linux.tar.gz

RUN ln -s /app/bin/cardano-cli /usr/local/bin/cardano-cli && \
    ln -s /app/bin/cardano-node /usr/local/bin/cardano-node

RUN git clone https://github.com/IntersectMBO/cardano-node.git && \
    cd cardano-node && \
    git checkout 9.2.1

RUN echo 'byronGenesisHash=$(cardano-cli byron genesis print-genesis-hash --genesis-json ./example/genesis/byron/genesis.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ByronGenesisHash: $byronGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

RUN echo 'alonzoGenesisHash=$(cardano-cli genesis hash --genesis ./example/genesis/shelley/genesis.alonzo.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "AlonzoGenesisHash: $alonzoGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

RUN echo 'conwayGenesisHash=$(cardano-cli genesis hash --genesis ./example/genesis/shelley/genesis.conway.json)' >> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ConwayGenesisHash: $conwayGenesisHash" >> ./example/configuration.yaml' >> cardano-node/scripts/babbage/mkfiles.sh

RUN echo 'START_TIME_UTC=$(${DATE} -d @$(cat ./example/genesis/byron/genesis.json | jq .startTime) --utc +%FT%TZ) && sed -i ./example/genesis/shelley/genesis.json -e "s/  \"systemStart\": \".*Z\"/  \"systemStart\": \"${START_TIME_UTC}\"/"' >> cardano-node/scripts/babbage/mkfiles.sh
RUN echo 'shelleyGenesisHash=$(cardano-cli genesis hash --genesis ./example/genesis/shelley/genesis.json)'>> cardano-node/scripts/babbage/mkfiles.sh &&\
    echo 'echo "ShelleyGenesisHash: $shelleyGenesisHash" >> ./example/configuration.yaml'>> cardano-node/scripts/babbage/mkfiles.sh

# https://cardano-foundation.github.io/cardano-wallet/user
# https://cardano-foundation.github.io/cardano-wallet/api/edge/
RUN curl -OL https://github.com/cardano-foundation/cardano-wallet/releases/download/v2024-09-03/cardano-wallet-v2024-09-03-linux64.tar.gz && \
    tar xvzf cardano-wallet-v2024-09-03-linux64.tar.gz && \
    rm -rf cardano-wallet-v2024-09-03-linux64.tar.gz

RUN curl -fsSL https://deno.land/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

CMD ["sleep", "infinity"]
