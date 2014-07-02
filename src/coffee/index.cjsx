React = require 'react'
manuscripts = require './collections/manuscripts'

Main = require './views/main'
LeftMenu = require './views/left-menu'

App = React.createClass
    render: ->
        <div className="app">
            <Main />
            <LeftMenu />
        </div>

document.addEventListener 'DOMContentLoaded', ->
    React.renderComponent <App />, document.body