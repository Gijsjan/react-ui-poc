Collection = require 'ampersand-collection'
Manuscript = require '../models/manuscript'
xhr = require 'funcky.req'

Manuscripts = Collection.extend
  url: '/json/manuscripts.json'
  model: Manuscript
  fetch: (options) ->
    req = xhr.get @url
    req.done (xhr) =>
      response = JSON.parse xhr.response
      @add response
      options.success()

manuscripts = new Manuscripts()
manuscripts.fetch
  success: ->
    console.log manuscripts

module.exports = manuscripts