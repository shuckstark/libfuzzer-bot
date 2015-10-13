#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

rm -rf func_cov_dir
mkdir func_cov_dir
cd func_cov_dir

export PATH=$HOME/llvm-build/bin:$PATH
SAN=-fsanitize=shift  # Some minimal sanitizer
COV=-fsanitize-coverage=func  # Only functions
CC="clang  $SAN $COV"   ../freetype2/configure > /dev/null 
make -j > /dev/null
clang++ -std=c++11  \
  ../freetype2/src/tools/ftfuzzer/ftfuzzer.cc \
  ../freetype2/src/tools/ftfuzzer/runinput.cc  \
  -fsanitize=shift \
  *.o -I ../freetype2/include -I . .libs/libfreetype.a  \
  -lbz2 -lz -lpng -lharfbuzz  -o run_inputs

# Dump the coverage.
rm -f *sancov
export UBSAN_OPTIONS=coverage=1
./run_inputs "$@" > /dev/null 2>&1

# This shell script is pretty horrible, eventually we'll get it replaced
# with something nicer.
echo ===================================================================
echo ==== FUNCTION-LEVEL COVERAGE: THESE FUNCTIONS ARE *NOT* COVERED ===
echo ===================================================================
sancov.py print *sancov  2> /dev/null |\
  sancov.py missing run_inputs 2> /dev/null |\
  llvm-symbolizer -obj run_inputs -inlining=0 -functions=none |\
  grep freetype2 |\
  sed "s#.*freetype2/##g" |\
  sort | cat -n

