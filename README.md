[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/abstract-node)](https://artifacthub.io/packages/search?repo=abstract-node)

# Abstract External Node:

This repository provides resources for deploying and managing nodes on the Abstract network. It includes configurations and scripts to facilitate the setup of both external nodes and associated services. 
The repository is structured to support the deployment of nodes using Docker and Docker Compose, simplifying the process of running an Abstract network node locally or on a server. 
Additionally, it offers configurations for monitoring tools like Prometheus and Grafana, enabling users to observe node performance and network metrics effectively.


## Docker Compose

Override the appropriate env file (`.env.testnet` or `.env.mainnet`) with any values you wish to adjust

### Mainnet
```sh
cd docker
docker compose --env-file .env.mainnet -f external-node.yml up -d
```

### Testnet
```sh
cd docker
docker compose --env-file .env.testnet -f external-node.yml up -d
```


## Railway
You can deploy a preconfigured node directly on Railway.

Ensure that both the `abstract-node` and `postgres` services are allocated at least 16GB of RAM, and that the `postgres` service volume has plenty of room to grow (at least 100GB allocated for a fresh node as of April 2025).

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/rzhVvU?referralCode=lBSmSt)
