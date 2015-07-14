CtagsProvider = require './ctags-provider'
getTagsFile = require './get-tags-file'

module.exports =
  ctagsProvider: null

  config:
    minimumPrefixLength:
      order: 1
      type: 'integer'
      default: 3
      minimum: 1
      maximum: 10
    caseInsensitive:
      order: 2
      type: 'boolean'
      default: true
    useSnippers:
      order: 3
      type: 'boolean'
      default: true
    useFuzzy:
      order: 4
      type: 'boolean'
      default: true
      description: 'executed only if there is no suggestions'
    disableBuiltinProvider:
      order: 10
      title: 'Disalbe Built-In Provider'
      type: 'boolean'
      default: false
    debug:
      order: 99
      type: 'boolean'
      default: false

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
