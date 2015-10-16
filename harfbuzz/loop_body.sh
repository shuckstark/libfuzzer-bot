#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

P=$(cd $(dirname $0) && pwd)

mkindex() {
  (cd /var/www/html/; sudo $P/mkindex.sh index.html *log)
}

BUCKET=gs://font-fuzzing-corpora/
export ASAN_OPTIONS=quarantine_size_mb=10 # Make asan less memory-hungry.
J=$(grep CPU /proc/cpuinfo | wc -l )

L=$(date +%Y-%m-%d-%H-%M-%S.log)
echo =========== STARTING $L ==========================
echo =========== PULL libFuzzer
(cd Fuzzer; svn up)
echo =========== PULL HarBuzz
(cd harfbuzz; git pull)
echo =========== SYNC CORPORA
mkdir -p CORPORA/ARTIFACTS
gsutil -m rsync -r $BUCKET/CORPORA CORPORA
echo =========== BUILDING
$P/build.sh asan_cov -fsanitize=address -fsanitize-coverage=edge,8bit-counters > asan_cov_build.log 2>&1 &
$P/build.sh func -fsanitize=shift -fsanitize-coverage=func > func_build.log 2>&1 &
wait
echo =========== FUZZING
./harfbuzz_asan_cov_fuzzer -max_len=2048 ./CORPORA/C1  -artifact_prefix=../CORPORA/ARTIFACTS -jobs=$J -workers=$J -max_total_time=60 > $L 2>&1
exit_code=$?
case $exit_code in
  0) prefix=pass
    ;;
  *) prefix=FAIL
    ;;
esac
echo =========== SYNC CORPORA BACK
gsutil -m rsync -r CORPORA $BUCKET/CORPORA
echo =========== UPDATE WEB PAGE
sudo mv $L /var/www/html/$prefix-$L
mkindex
echo =========== DONE
echo
echo
