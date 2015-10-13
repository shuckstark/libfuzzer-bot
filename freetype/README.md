This page describes an experimental fuzzer bot for [FreeType](freetype.org)

# Motivation

First, we want to help the [FreeType](http://www.freetype.org) project to find bugs 
using the Sanitizers 
([asan](clang.llvm.org/docs/AddressSanitizer.html), 
[msan](clang.llvm.org/docs/MemorySanitizer.html), ubsan, etc)
and [libFuzzer](llvm.org/docs/LibFuzzer.html).
Earlier, [20+ bugs](https://savannah.nongnu.org/search/?words=LibFuzzer&type_of_search=bugs&Search=Search&exact=1#options)
were found by running libFuzzer on a local machine.

Second, we want to use this bot to improve the tools (libFuzzer, Sanitizers, coverage, etc)
based on the feedback which we hope to get from the FreeType developers.

Third, we want to use this public bot as an example to build bots for other opensource projects.

This bot is deliberately made *very* simple, with minimalist interface. 
It is not based on any serious continuous integration (CI) tool
but just uses a simple shell script (!).
One day we may migrate to a proper CI tool, but this is not the current goal.

# Usage 

Just go to the [Fuzzer URL](http://104.197.184.140/) and check individual logs.

If the fuzzer has detected an error, the log name will have the "FAIL" prefix, otherwise the name will start with "pass".
The log files contain the fuzzer output followed by the list of *not covered* functions (file names and line numbers are given). If a bug is found, the fuzzer output will contain the error message and the reproducer. 

# Setup 
These are the basic steps to set up a similar bot. 

* Create a clean Linux VM. The following steps were tested on 
a [GCE](https://cloud.google.com/compute/) instance using Ubuntu 14.04
* Download and execute [setup.sh](setup.sh). This will install required packages, build the fresh version of Clang/LLVM, checkout and prepare the FreeType sources.
* Create a bucket on [Google Cloud Storage](https://cloud.google.com/storage) to store the test corpus, authenticate the bot to have access to this bucket, create the corpus directory in $HOME. (currently, it's named CORPORA/C3). 
* Run `./freetype-experiment/loop.sh`. This will start the infinite loop:
  * Rsync the test corpus from server to local dir.
  * Pull fresh FreeType
  * Pull fresh scrips (this repo)
  * Build the fuzzer
  * Run the fuzzer
  * Rsync the test corpus from local dir to server
  * Copy the log file to `/var/www/html` and update `/var/www/html/index.html`


# TODO
* Extend the fuzzer [target function](http://git.savannah.gnu.org/cgit/freetype/freetype2.git/diff/src/tools/ftfuzzer/ftfuzzer.cc) to cover more functionality while keep it reasonably fast.
* Extend the test corpus