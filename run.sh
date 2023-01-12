#!/usr/bin/env sh

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3080
docker compose up -d
PORT=5900
TO=55500
for i in $(seq 0 100); do
    # add port with i
    P=$((PORT + i))
    T=$((TO + i))

    novnc --listen $T --vnc localhost:$P &>> /dev/null  &
    echo $! >> ./novnc.pid
done
python -m http.server &>> /dev/null &
echo $! >> novnc.pid

gns3server --config ./server.conf

for pid in $(cat ./novnc.pid); do
    kill -KILL "$pid"
done
rm ./novnc.pid
