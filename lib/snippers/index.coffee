path = require 'path'

module.exports =
class Snippers

  @snipperNames = [
    'coffee'
    'default'
  ]

  snippers: new Map

  constructor: ->
    @constructor.snipperNames.forEach((name) =>
      Snipper = require "./#{name}"
      snipper = new Snipper
      for extension in snipper.extensions
        @snippers.set(extension, snipper)
    )

  generate: (tag) ->
    {file: filePath} = tag

    fileExtension = path.extname(filePath)
    fileExtension = fileExtension.substr(1)

    snipper = @getSnipper({extension: fileExtension})
    return unless snipper

    snipper.generate(tag)

  getSnipper: ({extension}) ->
    @snippers.get(extension)
