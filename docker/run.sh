#! /bin/bash
if [ "$1" != "mainnet" ] && [ "$1" != "testnet" ]; then
    echo "Error: First argument must be either 'mainnet' or 'testnet'" >&2
    exit 1
fi
if [ "$2" != "up" ] && [ "$2" != "down" ]; then
    echo "Error: Second argument must be either 'up' or 'down'" >&2
    exit 1
fi

ENV_FILE=".env.$1"
if [ "$2" == "up" ]; then
  DIRECTION="up -d"
else
  DIRECTION="down"
fi

docker compose --env-file $ENV_FILE -f external-node.yml $DIRECTION
