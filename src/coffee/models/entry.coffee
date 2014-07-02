Model = require 'ampersand-state'

Entry = Model.extend
  props:
    manuscript: 'string'
    subDivs: 'array'
    n: 'string'
    startPage: 'string'
    type: 'string'
    head: 'string'
    date: 'string'
    url: 'string'

module.exports = Entry