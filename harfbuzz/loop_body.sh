#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

export PATH=$HOME/llvm-build/bin:$PATH
P=$(cd $(dirname $0) && pwd)

mkindex() {
  (cd /var/www/html/; sudo $P/mkindex.sh index.html *log)
}

dump_coverage() {
  echo ===================================================================
  echo ==== FUNCTION-LEVEL COVERAGE: THESE FUNCTIONS ARE *NOT* COVERED ===
  echo ===================================================================
  sancov.py print *sancov  2> /dev/null |\
    sancov.py missing $1 2> /dev/null |\
    llvm-symbolizer -obj $1 -inlining=0 -functions=none |\
    grep /func/ |\
    sed "s#.*func/##g" |\
    sort --field-separator=: --key=1,1 --key=2n,2 --key=3n,3 | cat -n
}

BUCKET=gs://font-fuzzing-corpora
CORPUS=CORPORA/C1
MAX_LEN=1024
MAX_TOTAL_TIME=7200
export ASAN_OPTIONS=quarantine_size_mb=10 # Make asan less memory-hungry.
J=$(grep CPU /proc/cpuinfo | wc -l )

L=$(date +%Y-%m-%d-%H-%M-%S.log)
echo =========== STARTING $L ==========================
echo =========== PULL libFuzzer && (cd Fuzzer; svn up)
echo =========== PULL HarBuzz   && (cd harfbuzz; git pull)
echo =========== SYNC CORPORA and BUILD
mkdir -p CORPORA/ARTIFACTS
# These go in parallel.
(gsutil -m rsync -r $BUCKET/CORPORA CORPORA; gsutil -m rsync -r CORPORA $BUCKET/CORPORA) &
$P/build.sh asan_cov -fsanitize=address -fsanitize-coverage=edge,8bit-counters > asan_cov_build.log 2>&1 &
$P/build.sh func -fsanitize=shift -fsanitize-coverage=func > func_build.log 2>&1 &
wait

echo =========== FUZZING
./harfbuzz_asan_cov_fuzzer -max_len=$MAX_LEN $CORPUS  -artifact_prefix=CORPORA/ARTIFACTS/ -jobs=$J -workers=$J -max_total_time=$MAX_TOTAL_TIME > $L 2>&1
exit_code=$?
case $exit_code in
  0) prefix=pass
    ;;
  *) prefix=FAIL
    ;;
esac
echo =========== DUMP COVERAGE
rm -f *sancov
UBSAN_OPTIONS=coverage=1 ./harfbuzz_func_fuzzer -max_len=$MAX_LEN $CORPUS -runs=0 > func_run.log 2>&1
dump_coverage harfbuzz_func_fuzzer >> $L
echo =========== UPDATE WEB PAGE
sudo mv $L /var/www/html/$prefix-$L
mkindex
echo =========== DONE
echo
echo
