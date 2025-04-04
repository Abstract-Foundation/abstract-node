#! /bin/bash
if [ "$1" != "mainnet" ] && [ "$1" != "testnet" ]; then
    echo "Error: First argument must be either 'mainnet' or 'testnet'" >&2
    exit 1
fi

ENV_FILE=".env.$1"

docker compose --env-file $ENV_FILE -f external-node.yml up -d
