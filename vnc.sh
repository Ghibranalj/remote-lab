#!/usr/bin/env sh

PORT=5900
TO=55500
for i in $(seq 0 100); do
    # add port with i
    P=$((PORT + i))
    T=$((TO + i))

    novnc --listen $T --vnc localhost:$P &>> /dev/null  &
    echo $! >> ./novnc.pid
done
python3 -m http.server

killall python3
