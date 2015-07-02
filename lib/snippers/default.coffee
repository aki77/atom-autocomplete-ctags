Snipper = require './snipper'

module.exports =
class DefaultSnipper extends Snipper

  extensions: ['m']

  generate: (tag) ->
    return null if tag.kind isnt 'f'

    argsString = ''
    matches = tag.pattern.match(/\(([^\(\)]*)\)/)
    argsString = matches[1].trim() if matches
    snippetCount = 1
    args = []

    if argsString.length > 0
      args = argsString.split(',').map((arg) ->
        [arg] = arg.split('=', 1)
        "${#{snippetCount++}:#{arg.trim()}}"
      )

    "#{tag.name}(#{args.join(', ')})${#{snippetCount}}"
