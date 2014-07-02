React = require 'react'

MainMenu = React.createClass
    handleClick: (ev) ->
    render: ->
        <header>
            <button onClick={@handleClick}>
                <svg width="30" height="27" viewBox="0 0 30 27">
                    <rect x="0" y="0" height="7" width="30" rx="2" ry="2" />
                    <rect x="0" y="10" height="7" width="30" rx="2" ry="2" />
                    <rect x="0" y="20" height="7" width="30" rx="2" ry="2" />
                </svg>
            </button>
        </header>

module.exports = MainMenu