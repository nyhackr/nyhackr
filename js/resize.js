
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
  cardPosition.left =  cardPosition.left + $('.home-card').width() - 40 //90
  $("#tickets-tag").css(cardPosition)
  
  // show ticket divs on desktop
  // js instead of css so it can wait for the image to load
  if ($(window).width() > tabletWidth) {
     $("#tickets-tag").show()
  } else {
     $("#tickets-tag").hide()
  }
}

window.addEventListener('load', resizeTablet)
$(window).resize(resizeTablet)
