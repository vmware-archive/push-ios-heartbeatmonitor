#!/bin/bash

set -ex

if [ "$1" != "" ]; then
  if [ "$2" != "" ]; then
    ROUTE=$1
    HOST=$2
    FULL_ROUTE=${1}.${2}
  else
    # Default host is cf-app.com
    ENV=$1
    FULL_ROUTE=push-api.${ENV}.cf-app.com
  fi

  echo "### Modifying build for the $FULL_ROUTE environment."

  # Replace the environment name in the Info.plist file
  sed -i "" "/<key>NSExceptionDomains<\\/key>/{ # Find the NSExceptionDomains key

    # Skip past two lines
    n;n

    # Change the next line
    c\\
    \\                       <key>${FULL_ROUTE}</key>
    }" heartbeat/heartbeat/Info.plist

  # Replace the environment name in the Pivotal.plist file
  sed -i "" "/<key>pivotal.push.serviceUrl<\\/key>/{ # Find the NSExceptionDomains key
    # Skip to the next line
    n

    # Change the next line
    c\\
    \\       <string>https://${FULL_ROUTE}</string>
    }" heartbeat/heartbeat/Pivotal.plist
fi

# Produce the build archive
xcodebuild \
  -xcconfig heartbeat/heartbeat/heartbeat-config.xcconfig \
  -project "heartbeat/PCF Push Heartbeat Monitor.xcodeproj" \
  -scheme "PCF Push Heartbeat Monitor" \
  -archivePath build/PCFPushHeartbeatMonitor.xcarchive \
  archive

# Exports the build archive as an IPA file
xcodebuild \
  -exportArchive \
  -xcconfig heartbeat/heartbeat/heartbeat-config.xcconfig \
  -archivePath build/PCFPushHeartbeatMonitor.xcarchive \
  -exportPath build/PCFPushHeartbeatMonitor \
  -exportOptionsPlist scripts/export-options.plist
