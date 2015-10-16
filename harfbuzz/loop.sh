#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");
#
# Do the very minimal work here so that changes in other scripts
# take affect w/o needing to restart the loop.
P=$(cd $(dirname $0) && pwd)
echo $P
while true; do
  echo =========== PULL libfuzzer-bot
  (cd libfuzzer-bot; git pull)
  $P/loop_body.sh
done
