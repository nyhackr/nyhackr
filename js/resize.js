let mobileWidth = 428

function resizeMobile(){
  // resize cards
  if ($("#meetup-card-container").width() <= mobileWidth){
   $("#meetup-card-container .meetup-card").width("100%") 
  } else {
    $("#meetup-card-container .meetup-card").width("45%")
  }
}

//resizeMobile()
//$(window).resize(resizeMobile)


let tabletWidth = 767

function resizeTablet(){
  // adjust floating jobs div position
  let slackIconPosition = $(".fa-slack").offset()
  slackIconPosition.top = slackIconPosition.top + 40
  slackIconPosition.left = slackIconPosition.left - 5
  $("#jobs-tag").css(slackIconPosition)
  
  // remove floating jobs div
  if ($(window).width() <= tabletWidth) {
    $("#jobs-tag").hide()
  } else {
    $("#jobs-tag").show()
  }
}

resizeTablet()
$(window).resize(resizeTablet)
