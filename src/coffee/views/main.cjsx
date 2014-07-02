React = require 'react'
MainMenu = require './main-menu'

Main = React.createClass
    render: ->
        <div className="main">
            <MainMenu />
            <div className="main-body">
                <div className="left"></div>
                <div className="right"></div>
            </div>
        </div>

module.exports = Main