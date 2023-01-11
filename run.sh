#!/usr/bin/env sh

docker compose up -d
gns3server --config ./server.conf
