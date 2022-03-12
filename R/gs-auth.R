# Decrypt credentials file and authenticate Googlesheets
googlesheets4::gs4_auth(
  path = cyphr::decrypt(
    readLines("nyhackr-website.encrypted"),
    cyphr::key_sodium(sodium::hex2bin(Sys.getenv("CYPHR_KEY")))
  )
)

# id for google sheet
gsheet_id <- Sys.getenv('GSHEET_ID')
