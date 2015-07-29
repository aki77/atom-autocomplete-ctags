{CompositeDisposable}  = require 'atom'
{debug} = require './helper'
TagsFile = require './tags-file'
[ctags, Snippers, filter] = []

module.exports =
class CtagsProvider
  @kinds = {
    f: 'function'
    v: 'variable'
  }

  selector: '.source'
  disableForSelector: '.comment, .string, .source.gfm'
  inclusionPriority: 1
  suggestionPriority: 1
  # excludeLowerPriority: false

  tagsFiles: []
  snippers: null

  constructor: (tagsFiles = []) ->
    @subscriptions = new CompositeDisposable
    @observeConfig()
    @setTagsFiles(tagsFiles)

  observeConfig: ->
    @subscriptions.add(atom.config.observe('autocomplete-ctags.useSnippers', (value) =>
      if value
        Snippers ?= require './snippers'
        @snippers = new Snippers
      else
        @snippers = null
    ))

    @subscriptions.add(atom.config.observe('autocomplete-ctags.disableBuiltinProvider', (disable) =>
      @excludeLowerPriority = disable
    ))

  setTagsFiles: (tagsFiles) ->
    @clearTagsFiles()
    @tagsFiles = tagsFiles.map((filePath) ->
      new TagsFile(filePath)
    )

  dispose: ->
    @subscriptions?.dispose()
    @subscriptions = null
    @clearTagsFiles()
    @snippers = null

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    if @tagsFiles.length is 0
      return Promise.resolve([])

    if prefix.length < atom.config.get('autocomplete-ctags.minimumPrefixLength')
      return Promise.resolve([])

    promises = @tagsFiles.map((tagsFile) =>
      @findTags(tagsFile, prefix)
    )

    Promise.all(promises).then((tags) =>
      suggestions = tags.reduce((a, b) ->
        a.push(b...)
      ).map((tag) =>
        text: tag.name
        description: tag.pattern
        type: @constructor.kinds[tag.kind] ? null
        snippet: @snippers?.generate(tag)
      )

      debug('getSuggestions', suggestions)
      suggestions
    )

  findTags: (tagsFile, prefix) ->
    ctags ?= require 'ctags'

    new Promise((resolve, reject) =>
      options =
        partialMatch: true
        caseInsensitive: atom.config.get('autocomplete-ctags.caseInsensitive')
      ctags.findTags(tagsFile.getPath(), prefix, options, (error, tags = []) =>
        debug('findTags', error, tags)

        return reject(error) if error
        if tags.length is 0 and atom.config.get('autocomplete-ctags.useFuzzy')
          tags = @fuzzyFindTags(tagsFile, prefix)

        resolve(tags)
      )
    )

  fuzzyFindTags: (tagsFile, prefix) ->
    cachedTags = tagsFile.getCachedTags()
    return [] if cachedTags.length is 0
    filter ?= require('fuzzaldrin').filter
    results = filter(cachedTags, prefix, key: 'name')
    debug('fuzzyFindTags', results)
    Promise.resolve(results)

  clearTagsFiles: ->
    for tagsFile in @tagsFiles
      tagsFile.destroy()
    @tagsFiles = []
