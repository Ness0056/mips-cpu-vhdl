#!/usr/bin/env bash

if [ "${DISPLAY}" = "" ]; then
    echo "Keine grafische Oberfläche gefunden"
    echo "Nutze Broadway für Webdarstellung"#
    BROADWAY_PORT=$((8080+$UID))
    if ! lsof -i:$((8080+$UID)) -s TCP:LISTEN > /dev/null; then
        broadwayd :$UID &
    fi
    export GDK_BACKEND=broadway
    export BROADWAY_DISPLAY=:$UID
fi

if [ -f "waveform.ghw" ]; then
    gtkwave -mtranscript waveform.ghw &
elif [ -f "waveform.vcd.gz" ]; then
    gtkwave -mtranscript waveform.vcd.gz &
else
    echo "Keine Waveform gefunden";
    exit 1; \
fi

if [ ! -z "${BROADWAY_PORT}" ]; then
    echo "GTKWave ist jetzt unter \"http://localhost:$BROADWAY_PORT\" abrufbar."
fi
