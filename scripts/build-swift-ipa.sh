#!/bin/bash

set -ex

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
