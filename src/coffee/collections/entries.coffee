Collection = require 'ampersand-collection'
Entry = require '../models/entry'

Entries = Collection.extend
  model: Entry

module.exports = Entries