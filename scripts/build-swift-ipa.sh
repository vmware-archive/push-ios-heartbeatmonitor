#!/bin/bash

set -ex

ENV=$1

if [ "$ENV" != "" ]; then

  echo "### Modifying build for the $ENV environment."

  # Replace the environment name in the Info.plist file
  sed -i "" "/<key>NSExceptionDomains<\\/key>/{ # Find the NSExceptionDomains key

    # Skip past two lines
    n;n

    # Change the next line
    c\\
    \\                       <key>push-api.${ENV}.cf-app.com</key>
    }" heartbeat/heartbeat/Info.plist

  # Replace the environment name in the Pivotal file
  sed -i "" "/<key>pivotal.push.serviceUrl<\\/key>/{ # Find the NSExceptionDomains key
    # Skip to the next line
    n

    # Change the next line
    c\\
    \\       <string>https://push-api.${ENV}.cf-app.com</string>
    }" heartbeat/heartbeat/Pivotal.plist
fi

# Produce the build archive
xcodebuild \
  -project "heartbeat/PCF Push Heartbeat Monitor.xcodeproj" \
  -scheme "PCF Push Heartbeat Monitor" \
  -archivePath build/PCFPushHeartbeatMonitor.xcarchive \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -archivePath build/PCFPushHeartbeatMonitor.xcarchive \
  -exportPath build/PCFPushHeartbeatMonitor \
  -exportOptionsPlist scripts/export-options.plist
