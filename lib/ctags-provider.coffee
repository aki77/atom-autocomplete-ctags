{CompositeDisposable}  = require 'atom'
[ctags, Snippers] = []

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

  constructor: (@tagsFiles = []) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.config.observe('autocomplete-ctags.useSnippers', (value) =>
      if value
        Snippers ?= require './snippers'
        @snippers = new Snippers
      else
        @snippers = null
    ))

    @subscriptions.add(atom.config.observe('autocomplete-ctags.disableBuiltinProvider', (disable) =>
      # autocomplete-plus bug
      if disable
        @excludeLowerPriority = true
      else
        delete @excludeLowerPriority
    ))

  setTagsFiles: (@tagsFiles) ->

  dispose: ->
    @subscriptions?.dispose()
    @subscriptions = null
    @tagsFiles = []
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

      if atom.config.get('autocomplete-ctags.debug')
        console.log 'CtagsProvider.getSuggestions', suggestions
      suggestions
    )

  findTags: (tagsFile, prefix) ->
    ctags ?= require 'ctags'

    new Promise((resolve, reject) ->
      options =
        partialMatch: true
        caseInsensitive: atom.config.get('autocomplete-ctags.caseInsensitive')
      ctags.findTags(tagsFile, prefix, options, (error, tags = []) ->
        if atom.config.get('autocomplete-ctags.debug')
          console.log 'CtagsProvider.findTags', error, tags

        return reject(error) if error
        resolve(tags)
      )
    )
