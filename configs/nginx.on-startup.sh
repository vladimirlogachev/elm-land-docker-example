#!/bin/sh

# Note: -e = exit on error, -u = exit on undefined variable
set -eu

# ------- Set robots.txt -------

# Specify robots.txt path
robotsTxtFile="/usr/share/nginx/html/robots.txt"

# Determine the disallow value based on the env variable
if [ "$WEBAPP_ALLOW_INDEXING" = "true" ]; then
  disallow_value=
else
  disallow_value=/
fi

# Update the robots.txt file
sed -i "s#^Disallow:.*#Disallow: $disallow_value#" "$robotsTxtFile"

# ------- Set other env variables in config.json -------

# Create a temporary file for in-place updates
tempFile="/tmp/config.temp.json"

# Specify config path
configFile="/usr/share/nginx/html/nocache/config.json"

# Update config from env variables, 1 line per 1 variable.
jq --arg a "$WEBAPP_BACKEND_URL" '.backendUrl = $a' "$configFile" >"$tempFile" && mv "$tempFile" "$configFile"
# And more: jq --arg ...
