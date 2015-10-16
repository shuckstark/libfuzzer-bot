font-fuzzing-corpora
--------------------

Fuzzers for font parsers, such as [./freetype] need extensive seed corpora
to be efficient.

We are using seed inputs from the following sources:
* [Chromium sourcess](http://dev.chromium.org)
* [Skia](https://github.com/google/skia)
* [Harfbuzz](http://cgit.freedesktop.org/harfbuzz)
* Fonts from Ubuntu (install all font-related packages, then loot
  `/usr/share/fonts`)
