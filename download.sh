#!/bin/bash

# Set the repository
REPO="DataTalksClub/nyc-tlc-data"

# Get the latest release tag
LATEST_TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | jq -r '.tag_name')

# Construct the GitHub API URL using the latest tag
API_URL="https://api.github.com/repos/${REPO}/releases/tags/${LATEST_TAG}"

# Fetch the release information using curl and jq
RELEASE_INFO=$(curl -s "${API_URL}" | jq -r '.')


# Check if the release exists. If not, exit
if [[ -z "$RELEASE_INFO" ]]; then
  echo "Error: Could not find release information for tag ${LATEST_TAG}.  Check the repository."
  exit 1
fi


# Extract the assets URL
ASSETS_URL=$(echo "${RELEASE_INFO}" | jq -r '.assets_url')

# Fetch the assets information
ASSETS_INFO=$(curl -s "${ASSETS_URL}" | jq -r '.')

# Loop through the assets and download each one
echo "${ASSETS_INFO}" | jq -r '.[] | .browser_download_url' | while read URL; do
  FILENAME=$(echo "${URL}" | awk -F'/' '{print $NF}') # Extract filename
  echo "Downloading ${FILENAME} from ${URL}..."

  # Check if the file already exists. If so, skip it.
  if [[ -f "$FILENAME" ]]; then
    echo "File ${FILENAME} already exists. Skipping."
  else
    curl -L "${URL}" -o "${FILENAME}" # Download and save with original filename
    echo "Downloaded ${FILENAME}"
  fi
done

echo "Download complete."
