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

  activate: (state) ->
    tagsFiles = @getTagsFiles()
    if tagsFiles.length > 0
      @ctagsProvider = new CtagsProvider(tagsFiles)

  deactivate: ->
    @ctagsProvider?.dispose()
    @ctagsProvider = null

  getTagsFiles: ->
    tagsFiles = []
    for projectPath in atom.project.getPaths()
      tagsFile = getTagsFile(projectPath)
      tagsFiles.push(tagsFile) if tagsFile?
    tagsFiles

  provide: ->
    @ctagsProvider ? []
