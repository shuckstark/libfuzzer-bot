#!/bin/bash
# Copyright 2015 Google Inc. All Rights Reserved.
# Licensed under the Apache License, Version 2.0 (the "License");

# Usage:
# mkindex.sh /path/to/index.html file1 file2 ...

index=$1
shift
recent=$(ls -t $@ | head -100)
mk() {
  echo "<html>"
  for r in $recent; do
    echo "<a href='"$r"'>"$r"</a><BR>"
  done
  echo "</html>"
}
mk > $index
