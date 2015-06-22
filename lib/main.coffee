CtagsProvider = require './ctags-provider'
getTagsFile = require './get-tags-file'

module.exports =
  ctagsProvider: null

  config:
    minimumPrefixLength:
      type: 'integer'
      default: 3
      minimum: 1
      maximum: 10
    caseInsensitive:
      type: 'boolean'
      default: true

  activate: (state) ->
    @ctagsProvider = new CtagsProvider

    @getTagsFiles().then((tagsFiles) =>
      @ctagsProvider.setTagsFiles(tagsFiles)
    )

  deactivate: ->
    @ctagsProvider?.dispose()
    @ctagsProvider = null

  getTagsFiles: ->
    new Promise (resolve) ->
      promises = atom.project.getPaths().map((projectPath) ->
        getTagsFile(projectPath)
      )

      Promise.all(promises).then((results) ->
        tagsFiles = results.filter((tagsFile) -> tagsFile isnt false)
        resolve(tagsFiles)
      )

  provide: ->
    @ctagsProvider
