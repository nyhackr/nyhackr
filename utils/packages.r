packages <- c()

purrr::map(packages, library, character.only=TRUE)