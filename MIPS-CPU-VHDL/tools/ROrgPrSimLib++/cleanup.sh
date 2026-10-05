#!/usr/bin/env bash

rm -f rorgprsimlib-obj08.cf

for src in vhdl/*.vhd; do
    name="$(basename $src .vhd)"
    rm -f "$name.o"
done
