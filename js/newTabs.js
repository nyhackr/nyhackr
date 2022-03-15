// open all external links in a new tab
let all_links = document.querySelectorAll('a');
for (var i = 0; i < all_links.length; i++){
       let a = all_links[i];
       if(a.hostname != location.hostname) {
               a.rel = 'noopener';
               a.target = '_blank';
       }
}
