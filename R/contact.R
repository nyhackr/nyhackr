render_contact_form <- function(){
  htmltools::div(
    class = 'contact-container',
    htmltools::HTML(
      '
      <form
        action="https://formspree.io/f/mvolredg"
        method="POST"
      >
        <label>Your email:</label>
        <input type="email" name="email">
        <br>
        
        <label>Your name:</label>
        <input type="name" name="name">
        <br>
        
        <label>Your message:</label>
        <textarea name="message"></textarea>
        <br>
        
        <button type="submit" class="btn btn-primary">Submit</button>
      </form>
      '
    )
  )
}
