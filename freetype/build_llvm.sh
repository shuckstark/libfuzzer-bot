#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
cd
rm -rf llvm-build
mkdir llvm-build
cd llvm-build
cmake -DCMAKE_BUILD_TYPE=Release -G Ninja $HOME/llvm
ninja check-asan check-clang check-llvm
