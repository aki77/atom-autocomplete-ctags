_ = require 'underscore-plus'
Snippers = require '../lib/snippers'

describe "Snippers", ->
  snippers = new Snippers
  [defaultTag] = []

  beforeEach ->
    defaultTag =
      kind: 'f'
      name: 'func'
      pattern: '/^  func: (arg) ->$/'

  describe "getSnipper", ->

    it "return Snipper", ->
      snipper = snippers.getSnipper({extension: 'coffee'})
      expect(snipper.constructor.name).toEqual('CoffeeSnipper')

  describe "generate", ->

    describe "coffee", ->
      beforeEach ->
        defaultTag.file = 'test.coffee'

      it "no arguments", ->
        pattern = '/^  func: ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func()${1}')

      it "no arguments with parentheses", ->
        pattern = '/^  func: () ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func()${1}')

      it "one arguments", ->
        pattern = '/^  func: (arg1) ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:arg1})${2}')

      it "two arguments", ->
        pattern = '/^  func: (arg1, arg2) ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:arg1}, ${2:arg2})${3}')

      it "default values for arguments", ->
        pattern = '/^  func: (arg1, arg2, arg3 = "coffee") ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:arg1}, ${2:arg2}, ${3:arg3})${4}')

      it "splats arguments", ->
        pattern = '/^  func: (arg1, arg2, arg3...) ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:arg1}, ${2:arg2}, ${3:arg3...})${4}')

      it 'destructuring assignment array', ->
        pattern = '/^  func: ([arg1, arg2, arg3]) ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:[arg1, arg2, arg3]})${2}')

      it 'destructuring assignment object', ->
        pattern = '/^  func: ({arg1, arg2, arg3}) ->$/'
        tag = _.defaults({pattern}, defaultTag)
        snippet = snippers.generate(tag)
        expect(snippet).toEqual('func(${1:\\{arg1, arg2, arg3\\}})${2}')

    describe "default", ->
      describe "Matlab", ->
        beforeEach ->
          defaultTag.file = 'test.m'

        it "one arguments", ->
          pattern = '/^function [m,s] = func(arg1)$/'
          tag = _.defaults({pattern}, defaultTag)
          snippet = snippers.generate(tag)
          expect(snippet).toEqual('func(${1:arg1})${2}')
