#!/bin/bash
curl -OL https://github.com/txpipe/oura/releases/download/v1.9.0/oura-aarch64-apple-darwin.tar.gz
tar xvzf oura-aarch64-apple-darwin.tar.gz
rm -rf oura-aarch64-apple-darwin.tar.gz

./oura daemon --config ./daemon.toml
socat UNIX-LISTEN:./cardano.sock,fork,reuseaddr,mode=755 TCP:192.168.20.105:1234 &
