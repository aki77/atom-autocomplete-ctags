path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

describe "AutocompleteCtags", ->
  [editor, provider, directory] = []

  getCompletions = ->
    cursor = editor.getLastCursor()
    start = cursor.getBeginningOfCurrentWordBufferPosition()
    end = cursor.getBufferPosition()
    prefix = editor.getTextInRange([start, end])
    request =
      editor: editor
      bufferPosition: end
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
    provider.getSuggestions(request)

  beforeEach ->
    atom.config.set('autocomplete-ctags.minimumPrefixLength', 3)

    atom.project.setPaths([
      temp.mkdirSync("other-dir-")
      temp.mkdirSync('atom-autocomplete-ctags')
    ])

    directory = atom.project.getDirectories()[1]
    fs.copySync(path.join(__dirname, 'fixtures', 'js'), atom.project.getPaths()[1])

    waitsForPromise ->
      atom.packages.activatePackage('autocomplete-ctags').then (pack) ->
        provider = pack.mainModule.provide()

  describe "js files", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open(directory.resolve('new.js')).then (_editor) ->
          editor = _editor

    it "return tag completions", ->
      editor.setText('c')

      waitsForPromise ->
        getCompletions().then((completions) ->
          expect(completions).toHaveLength 0
        )

      runs ->
        editor.setText('cal')
        editor.setCursorBufferPosition([0, 3])

      waitsForPromise ->
        getCompletions().then((completions) ->
          expect(completions).toHaveLength 1
          [completion] = completions
          expect(completion.text.length).toBeGreaterThan 0
          expect(completion.type).toBe 'function'
        )
