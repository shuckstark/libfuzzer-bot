font-fuzzing-corpora
--------------------

Fuzzers for font parsers, such as [freetype](./freetype/README.md) need extensive seed corpora
to be efficient.

We are using seed inputs from the following sources:
* [Chromium sourcess](http://dev.chromium.org)
* [Skia](https://github.com/google/skia)
* [Harfbuzz](http://cgit.freedesktop.org/harfbuzz)
* https://github.com/google/fonts
* Fonts from Ubuntu (install all font-related packages, then loot
  `/usr/share/fonts`)
* https://github.com/adobe-fonts
