# nyhackr

## How to contribute

If you wish to contribute to the website the process is pretty simple.

1. Fork and clone the repository (an example can be found [here](https://help.github.com/articles/fork-a-repo/))
2. Create a new branch for your changes (warning, this step cannot be done in RStudio!)
3. Make your changes. You can build and view your local version by using `rmarkdown::render_site()`
4. When you are done, [submit a pull request](https://help.github.com/articles/about-pull-requests/). Your changes might not appear on the public site right away as we have a development version for making sure changes don't break the site.

### Data access

An .Renviron file is required to access the data stored on Google Drive. Email Jared Lander to get access.

### How to manually update the site with the latest events

``` r
# update data from MeetUp
source('update-data/update_data.R')

# build the static site to _site/
rmarkdown::render_site()
```

The site is built using Rmarkdown. `_site.yml` controls the site layout and the individual `*.Rmd` files control each page. Data is pulled from the MeetUp API and stored within Google Sheets. On render, the site pulls the latest data from Google Sheets to build the site.

After each event, update the `[topics, videoURL, slidesTitle, slidesURL, speaker, cardURL]` columns on the "Talks" tab within the Google Sheet. Data should be in tidy format with each row representing a presentation at a given event. E.g. a MeetUp with two presentations will have two rows with duplicate information for the columns `[ID, meetupURL, date, venueID, venue, venueAddress, rsvpCount, meetupTitle, descriptionHTML]`. If there are two speakers for one presentation then there should be one row with their names concatenated in the `speaker` column.

Edit the individual `*.Rmd` files to update any static text.

### Site hosting

The site is hosted on GitHub Pages and built via GitHub Actions. The site rebuilds on push, daily at midnight, and on a manual trigger within the [Actions tab](https://github.com/nyhackr/nyhackr/actions/workflows/render-rmarkdown.yaml).

### Directory

    .
    ├── css/              CSS files to be included with rendered site
    ├── img/
    │   ├── books/
    │   ├── events/
    │   ├── meetups/
    │   └── sponsors/
    ├── includes/         HTML files to include as specified in _site.yml
    ├── js/               JavaScipt files to be included with rendered site
    ├── R/                R functions to pull/update data and format HTML 
    ├── renv/
    ├── update-data/      Script to update the talks data in Google Drive
    ├── _site.yml         Controls the site structure
    ├── about.Rmd         Renders to the about page
    ├── books.Rmd         Renders to the books page
    ├── contact.Rmd       Renders to the contact page
    ├── events.Rmd        Renders to the events page
    ├── index.Rmd         Renders to the home page
    ├── past-talks.Rmd    Renders to the past talks page
    ├── pizza.Rmd         Renders to the pizza page
    └── README.md


