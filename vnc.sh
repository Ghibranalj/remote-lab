#!/usr/bin/env sh
websockify :6080 --web /usr/share/novnc --token-plugin TokenFile --token-source $PWD/token &
python3 -m http.server

killall python3
killall websockify
