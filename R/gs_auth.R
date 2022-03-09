## copied from r-conference site

# Get secret key for decrypting file
key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("CYPHR_KEY")))

# Decrypt credentials file
decrypted_key <- cyphr::decrypt(readLines("nyhackr-website.encrypted"), key)

# Authenticate Googlesheets
googlesheets4::gs4_auth(path = decrypted_key)

# id for google sheet
gsheet_id <- Sys.getenv('GSHEET_ID')
