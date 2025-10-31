#!/bin/bash

src_file="$(find . -name "$1*")"
clang $src_file -O2 -o "solution"
./solution
