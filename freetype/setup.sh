#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
sudo apt-get update && sudo apt-get install git subversion g++ cmake ninja-build apache2 screen autoconf libtool libharfbuzz-dev libpng3-dev libbz2-dev zlib1g-dev:i386 libpng12-dev:i386 libharfbuzz-dev:i386 libbz2-dev:i386 -y
git clone https://github.com/kcc/libfuzzer-example.git
ln -s libfuzzer-example/freetype-experiment .

./freetype-experiment/get_llvm.sh
./freetype-experiment/build_llvm.sh

git clone git://git.sv.nongnu.org/freetype/freetype2.git
(cd freetype2/ && ./autogen.sh)
svn co http://llvm.org/svn/llvm-project/llvm/trunk/lib/Fuzzer
