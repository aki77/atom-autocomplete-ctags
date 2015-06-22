ctags = null
loadClasses = ->
  ctags = require 'ctags'

module.exports =
class CtagsProvider
  @kinds = {
    f: 'function'
    v: 'variable'
  }

  selector: '*'
  disableForSelector: '.comment, .string'
  inclusionPriority: 1
  suggestionPriority: 2

  tagsFiles: []

  constructor: (@tagsFiles = []) ->

  setTagsFiles: (@tagsFiles) ->

  dispose: ->
    @configSubscription?.dispose()
    @configSubscription = null
    @tagsFiles = []

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    if @tagsFiles.length is 0
      return Promise.resolve([])

    if prefix.length < atom.config.get('autocomplete-ctags.minimumPrefixLength')
      return Promise.resolve([])

    promises = @tagsFiles.map((tagsFile) =>
      @findTags(tagsFile, prefix)
    )

    Promise.all(promises).then((tags) =>
      tags.reduce((a, b) ->
        a.push(b...)
      ).map((tag) =>
        text: tag.name
        description: tag.pattern
        type: @constructor.kinds[tag.kind] ? null
      )
    )

  findTags: (tagsFile, prefix) ->
    loadClasses() unless ctags

    new Promise((resolve) ->
      options =
        partialMatch: true
        caseInsensitive: atom.config.get('autocomplete-ctags.caseInsensitive')
      ctags.findTags(tagsFile, prefix, options, (error, tags = []) ->
        resolve(tags)
      )
    )
