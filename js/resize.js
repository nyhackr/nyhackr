
let tabletWidth = 767

function resizeTablet(){
  // adjust floating jobs div position
  let slackIconPosition = $(".fa-slack").offset()
  slackIconPosition.top = 65
  slackIconPosition.left = slackIconPosition.left - 5
  $("#jobs-tag").css(slackIconPosition)
  
  // adjust tickets div position
  let cardPosition = $('.home-card').offset()
  cardPosition.top = cardPosition.top - 15
  cardPosition.left =  cardPosition.left + $('.home-card').width() - 90
  $("#tickets-tag").css(cardPosition)
  
  // remove divs on mobile
  // if ($(window).width() <= tabletWidth) {
  //   $("#jobs-tag, #tickets-tag").hide()
  // } else {
  //   $("#jobs-tag, #tickets-tag").show()
  // }
}

window.addEventListener('load', resizeTablet)
$(window).resize(resizeTablet)
