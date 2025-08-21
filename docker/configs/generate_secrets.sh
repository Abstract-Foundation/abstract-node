#!/bin/bash

if [ ! -s $1 ]; then
  /usr/bin/zksync_external_node generate-secrets | tail -n 4 > $1
fi
