path = require 'path'
fs = require 'fs'

isFileAsync = (filePath) ->
  new Promise((resolve, reject) ->
    fs.stat(filePath, (err, stats) ->
      if err
        resolve(false)
      else
        resolve(stats.isFile())
    )
  )

module.exports = (directoryPath) ->
  return Promise.reject() unless directoryPath?

  new Promise (resolve) ->
    filePaths = ['tags', 'TAGS', '.tags', '.TAGS'].map((fileName) ->
      path.join(directoryPath, fileName)
    )
    promises = filePaths.map((filePath) ->
      isFileAsync(filePath)
    )

    Promise.all(promises).then((results) ->
      for result, idx in results
        return resolve(filePaths[idx]) if result

      resolve(false)
    )
