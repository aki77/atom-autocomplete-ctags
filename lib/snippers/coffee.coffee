Snipper = require './snipper'

module.exports =
class CoffeeSnipper extends Snipper

  extensions: ['coffee']

  generate: (tag) ->
    return null if tag.kind isnt 'f'

    argsString = ''
    matches = tag.pattern.match(/\(([^\(\)]*)\)/)
    argsString = matches[1].trim() if matches
    snippetCount = 1
    args = []

    if argsString.match(/^[\{\[].+[\]\}]$/)
      # destructuring assignment
      argsString = argsString.replace(/([\{\}])/g, '\\$1')
      args = ["${#{snippetCount++}:#{argsString}}"]
    else if argsString.length > 0
      args = argsString.split(',').map((arg) ->
        [arg] = arg.split('=', 1)
        "${#{snippetCount++}:#{arg.trim()}}"
      )

    "#{tag.name}(#{args.join(', ')})${#{snippetCount}}"
