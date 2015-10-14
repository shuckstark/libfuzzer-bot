#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
sudo apt-get update && sudo apt-get install git subversion g++ cmake ninja-build apache2 screen autoconf libtool libharfbuzz-dev libpng3-dev libbz2-dev -y
git clone https://github.com/google/libfuzzer-bot.git

libfuzzer-bot/freetype/get_llvm.sh
libfuzzer-bot/freetype/build_llvm.sh

git clone git://git.sv.nongnu.org/freetype/freetype2.git
(cd freetype2/ && ./autogen.sh)
ln -sf llvm/lib/Fuzzer .
cp llvm/projects/compiler-rt/lib/sanitizer_common/scripts/sancov.py llvm-build/bin/
