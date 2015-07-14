fs = require 'fs'

getSize = (filePath) ->
  new Promise((resolve, reject) ->
    fs.stat(filePath, (error, stat) ->
      return reject(error) if error
      resolve(stat.size)
    )
  )

debug = (args...) ->
  return unless atom.config.get('autocomplete-ctags.debug')
  args.unshift('CtagsProvider')
  console.log(args...)


module.exports = {getSize, debug}
