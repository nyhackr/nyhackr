#!/bin/bash

# Check if a new event has been added to Meetup in last 24 hrs -
# if so trigger a build and deploy on Travis CI.

CHECK_INTERVAL=$(( 60 * 60 * 24 ))  # 60 secs / minute * 60 minute / hour * 24 hours / day

# Get time the next upcoming event was posted
CREATED_TIME=$(curl -s https://api.meetup.com/nyhackr/events?scroll=next_upcoming |
  jq '.[0].created')
CREATED_TIME=$(( $CREATED_TIME / 1000 ))  # Meetup API uses milliseconds since epoch

if [ $(( $(date +%s) - $CREATED_TIME )) -lt $CHECK_INTERVAL ]; then
  RESPONSE=$(curl -s -X POST \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -H 'Travis-API-Version: 3' \
    -H "Authorization: token $TRAVIS_API_TOKEN" \
    -d '{
      "request": {
        "branch": "master"
      }
    }' \
    https://api.travis-ci.org/repo/nyhackr%2Fnyhackr/requests)
  echo "$(date) - $RESPONSE"
else
  echo "$(date) - No new events in last $CHECK_INTERVAL seconds"
fi

