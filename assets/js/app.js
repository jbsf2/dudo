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
  console.log("playing audio")
  console.log(params)
  document.getElementById("dice-audio").play()
  window.shakeDice(params.player_id)
}

window.shakeDice = function(playerID) {
  var dice = document.querySelectorAll("ul#dice-" + playerID + " li.dice")
  console.log(dice)
  dice.forEach(function(d) {
    var startDelay = Math.random() * 200
    var endDelay = 1000 + (Math.random() * 500)
    console.log(startDelay)
    console.log(endDelay)
    window.shakeSingleDice(d, startDelay, endDelay)
  })
}

window.shakeSingleDice = function(element, startDelay, endDelay) {
  setTimeout(function() {
    console.log("adding class")
    element.classList.add("shake-slow")
  }, startDelay)

  setTimeout(function() {
    element.classList.remove("shake-slow")
  }, endDelay)

}
