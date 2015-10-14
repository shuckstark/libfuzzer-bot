#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

# set -x
set -e
set -u
export PATH=$HOME/llvm-build/bin:$PATH

cd
rm -rf fuzz_freetype
mkdir fuzz_freetype
cd fuzz_freetype

echo =========== PULL libFuzzer
ln -s ../Fuzzer .
(cd Fuzzer; svn up)

echo =========== PULL FreeType
(cd ../freetype2/ && git pull)

echo =========== CONFIGURE
SAN=-fsanitize=address,signed-integer-overflow,shift
COV=-fsanitize-coverage=edge,8bit-counters
CC="clang  $SAN $COV"   ../freetype2/configure > /dev/null 

echo =========== MAKE
make -j > /dev/null

echo =========== BUILD libFuzzer
for f in Fuzzer/*cpp; do clang++ -std=c++11 -c $f -IFuzzer & done
wait

echo =========== BUILD freetype2_fuzzer

clang++ -std=c++11  ../freetype2/src/tools/ftfuzzer/ftfuzzer.cc \
  -fsanitize=address -fsanitize-coverage=edge \
  *.o -I ../freetype2/include -I . .libs/libfreetype.a  \
  -lbz2 -lz -lpng -lharfbuzz  -o freetype2_fuzzer

echo =========== RUN freetype2_fuzzer
export ASAN_OPTIONS=quarantine_size_mb=10 # Make asan less memory-hungry.
J=$(grep CPU /proc/cpuinfo | wc -l )
./freetype2_fuzzer -max_len=20480 ../CORPORA/C4 -artifact_prefix=../CORPORA/ARTIFACTS/ -jobs=$J -workers=$J -max_total_time=7200
