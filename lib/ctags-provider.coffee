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

  minimumPrefixLength: 3

  constructor: (@tagsFiles) ->
    @configSubscription = atom.config.observe('autocomplete-ctags.minimumPrefixLength', (value) =>
      @minimumPrefixLength = value
    )

  dispose: ->
    @configSubscription?.dispose()
    @configSubscription = null
    @tagsFiles = []

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    if prefix.length < @minimumPrefixLength
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
    new Promise((resolve) ->
      options =
        partialMatch: true
        caseInsensitive: atom.config.get('autocomplete-ctags.caseInsensitive')
      ctags.findTags(tagsFile, prefix, options, (error, tags = []) ->
        resolve(tags)
      )
    )
