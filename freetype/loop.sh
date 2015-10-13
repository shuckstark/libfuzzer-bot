#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

P=$(cd $(dirname $0) && pwd)

mkindex() {
  (cd /var/www/html/; sudo $P/mkindex.sh index.html *log)
}

echo $P
while true; do
  echo =========== PULL libfuzzer-bot
  (cd libfuzzer-bot; git pull)
  L=$(date +%Y-%m-%d-%H-%M-%S.log)
  echo =========== Starting $L
  gsutil -m rsync -r gs://freetype-fuzzing-corpora/CORPORA CORPORA
  $P/fuzz_freetype.sh >  $L 2>&1
  exit_code=$?
  $P/dump_uncovered.sh `pwd`/CORPORA/C4/* >> $L 2>&1
  case $exit_code in
    0) prefix=pass
      ;;
    *) prefix=FAIL
      ;;
  esac
  gsutil -m rsync -r CORPORA gs://freetype-fuzzing-corpora/CORPORA
  grep -v /cff/ $L > t.log
  sudo cp t.log /var/www/html/$prefix-$L
  mkindex
done
