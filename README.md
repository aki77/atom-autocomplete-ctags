# autocomplete-ctags package

Autocomplete-plus provider for ctags
[![Build Status](https://travis-ci.org/aki77/atom-autocomplete-ctags.svg)](https://travis-ci.org/aki77/atom-autocomplete-ctags)

[![Gyazo](http://i.gyazo.com/007c0aef7ad4a05c1f94ee8ce6a00d41.gif)](http://gyazo.com/007c0aef7ad4a05c1f94ee8ce6a00d41)

## Features

* If your project has a tags/.tags/TAGS/.TAGS file at the root then autocomplete are supported.
* coexist with [symbols-view package](https://atom.io/packages/symbols-view)
* support multiple root folders.
* Snippet generator for ctags.
* fuzzy matching.

## Settings

* `minimumPrefixLength` (default: 3)
* `caseInsensitive` (default: true)
* `useSnippers` (default: true)
* `useFuzzy`: executed only if there is no suggestions (default: true)
* `maximumTagFileSize`: Maximum tag file size(in MB). This setting is used in fuzzy search. (default: 2)
* `disableBuiltinProvider` (default: false)

## Todo

* [x] fuzzy matching
* [ ] Add language snippers. (pull requests welcome!)
