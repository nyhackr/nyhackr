
let tabletWidth = 767

function resizeTablet(){
  // adjust floating jobs div position
  let slackIconPosition = $(".fa-slack").offset()
  slackIconPosition.top = 65
  slackIconPosition.left = slackIconPosition.left - 5
  $("#jobs-tag").css(slackIconPosition)
  
  // remove floating jobs div
  if ($(window).width() <= tabletWidth) {
    $("#jobs-tag").hide()
  } else {
    $("#jobs-tag").show()
  }
}

window.addEventListener('load', resizeTablet)
$(window).resize(resizeTablet)
