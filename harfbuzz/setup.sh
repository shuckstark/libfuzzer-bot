#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
sudo apt-get update && sudo apt-get install git subversion g++ cmake ninja-build apache2 screen autoconf libtool libharfbuzz-dev libpng3-dev libbz2-dev ragel libglib2.0-dev -y
git clone https://github.com/google/libfuzzer-bot.git

libfuzzer-bot/harfbuzz/get_llvm.sh
libfuzzer-bot/harfbuzz/build_llvm.sh

git clone https://github.com/behdad/harfbuzz.git
ln -sf llvm/lib/Fuzzer .
