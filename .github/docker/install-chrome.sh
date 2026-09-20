#!/bin/bash
set -euo pipefail

index=https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json
urls=$(curl -fsSL "$index" | ruby -rjson -e '
  downloads = JSON.parse($stdin.read).dig("channels", "Stable", "downloads")
  %w[chrome chromedriver].each { |kind| puts downloads[kind].find { |d| d["platform"] == "linux64" }["url"] }
')

for url in $urls; do
  curl -fsSL "$url" -o /tmp/chrome.zip
  unzip -q /tmp/chrome.zip -d /opt
done
rm /tmp/chrome.zip

printf '#!/bin/sh\nexec /opt/chrome-linux64/chrome --no-sandbox --disable-dev-shm-usage "$@"\n' > /usr/bin/google-chrome
chmod +x /usr/bin/google-chrome
ln -s /opt/chromedriver-linux64/chromedriver /usr/bin/chromedriver
