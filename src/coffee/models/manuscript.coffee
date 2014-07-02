State = require 'ampersand-state'
Entries = require '../collections/entries'

Manuscript = State.extend
  props:
    title: 'string'
    version: 'string'
    externalPatches: 'object'
    rtfs: 'array'
    pages: 'array'

  derived:
    entries:
      deps: ['pages']
      fn: ->
        new Entries(@pages)


module.exports = Manuscript