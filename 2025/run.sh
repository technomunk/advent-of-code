#!/bin/bash

src_file="$(find . -name "$1_*")"
clang $src_file lib/*.c -O2 -o "solution" -std=c11  -I. || exit
./solution
