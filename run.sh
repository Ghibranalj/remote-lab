#!/usr/bin/env sh

docker compose up -d
gns3server --config /root/gns3/config.conf
