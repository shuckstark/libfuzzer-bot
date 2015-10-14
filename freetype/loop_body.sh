#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

P=$(cd $(dirname $0) && pwd)

mkindex() {
  (cd /var/www/html/; sudo $P/mkindex.sh index.html *log)
}

L=$(date +%Y-%m-%d-%H-%M-%S.log)
echo =========== STARTING $L ==========================
echo =========== SYNC CORPORA
mkdir -p CORPORA
gsutil -m rsync -r gs://freetype-fuzzing-corpora/CORPORA CORPORA
echo =========== FUZZING
$P/fuzz_freetype.sh >  $L 2>&1
exit_code=$?
echo =========== COMPUTING CORPUS COVERAGE
$P/dump_uncovered.sh `pwd`/CORPORA/C4/* >> $L 2>&1
case $exit_code in
  0) prefix=pass
    ;;
  *) prefix=FAIL
    ;;
esac
echo =========== SYNC CORPORA BACK
gsutil -m rsync -r CORPORA gs://freetype-fuzzing-corpora/CORPORA
echo =========== UPDATE WEB PAGE
grep -v /cff/ $L > t.log
sudo cp t.log /var/www/html/$prefix-$L
mkindex
echo =========== DONE
echo
echo
