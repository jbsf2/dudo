// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"
import "../css/dudo.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

// assets/js/app.js
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}
Hooks.Dice = {
    mounted(){
      this.handleEvent("shake", (params) => window.handleShake(params))
    }
  }

Hooks.Button = {
  updated() {
    var button = this.el.querySelector("button")
    var el = this.el;

    setTimeout(function() {
      button.remove()
      el.appendChild(button)
    }, 100)
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.handleShake = function(params) {
  document.getElementById("dice-audio").play()
  window.shakeDice(params.player_id)
}

window.shakeDice = function(playerID) {
  var dice = document.querySelectorAll("ul#dice-" + playerID + " li.dice")
  const shakeClasses = ["shake-slow", "shake-slow-2", "shake-slow-3"]
  dice.forEach(function(d) {
    var startDelay = Math.random() * 200
    var endDelay = 1000 + (Math.random() * 500)
    var shakeClass = shakeClasses[Math.floor(Math.random() * 3)]
    window.shakeSingleDice(d, shakeClass, startDelay, endDelay)
  })
}

window.shakeSingleDice = function(element, shakeClass, startDelay, endDelay) {
  setTimeout(function() {
    element.classList.add(shakeClass)
  }, startDelay)

  setTimeout(function() {
    element.classList.remove(shakeClass)
  }, endDelay)

}
