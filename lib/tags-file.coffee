_ = require 'underscore-plus'
{getSize, debug} = require './helper'
[ctags, pathWatcher] = []

module.exports =
class TagsFile
  cachedTags: []
  watchSubscription: null

  constructor: (@filePath) ->
    @configSubscription = atom.config.observe('autocomplete-ctags.useFuzzy', @toggleCache)
    @debouncedUpdateCachedTags = _.debounce(@updateCachedTags, 1000)

  destroy: ->
    @configSubscription.dispose()
    @configSubscription = null
    @disableCache()

  toggleCache: (enabled) =>
    return unless enabled?

    if enabled
      @enableCache()
    else
      @disableCache()

  enableCache: ->
    debug 'enableCache'
    @updateCachedTags()
    @watch()

  disableCache: ->
    debug 'disableCache'
    @cachedTags = []
    @watchSubscription?.close()
    @watchSubscription = null

  updateCachedTags: =>
    @cachedTags = []

    getSize(@filePath).then((fileSize) =>
      debug 'tagsFilesize', fileSize
      return Promise.reject(new Error('large tagsFile')) if fileSize >= @maximumTagFileSize()
      @readTags().then((tags) =>
        @cachedTags = tags
        debug 'updateCachedTags', @cachedTags
      )
    )

  readTags: ->
    new Promise((resolve, reject) =>
      ctags ?= require 'ctags'
      stream = ctags.createReadStream(@filePath)
      result = []

      stream.on 'error', (error)->
        reject(error)

      stream.on 'data', (tags)->
        result.push(tags...)

      stream.on 'end', ->
        resolve(result)
    )

  watch: =>
    try
      pathWatcher ?= require 'pathwatcher'
      @watchSubscription ?= pathWatcher.watch(@filePath, (eventType) =>
        debug 'watch', eventType
        switch eventType
          when 'change'
            @debouncedUpdateCachedTags() if @watchSubscription?
          # support mv
          when 'delete'
            @disableCache()
            @watch()
            @debouncedUpdateCachedTags()
      )
    catch error
      console.error error


  getPath: ->
    @filePath

  toString: ->
    @getPath()

  getCachedTags: ->
    @cachedTags

  maximumTagFileSize: ->
    atom.config.get('autocomplete-ctags.maximumTagFileSize') * 1048576
