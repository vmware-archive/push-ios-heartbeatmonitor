# Push iOS Heartbeat Monitor

The Heartbeat Monitor was designed to help PCF operators ensure their Push Notification service is running correctly end-to-end and provide historical data. The PCF Push tile deploys Heartbeat App in the push-service-instance in the `push-notifications` space of the `system` org. The app sends a "heartbeat" push every minute to every device subscribed to the `pcf.push.heartbeat` topic. The Heartbeat Monitor subscribes to the heartbeat topic and responds to the server every time it receives a heartbeat.

## Pre-requisites

This app requires release v1.5.0+ of the [PCF Push Notification Tile](https://network.pivotal.io/products/push-notification-service#/releases/) to work. Heartbeat App will automatically be installed in your push-service-instance. 

__Note:__ Make sure you have added a valid p12 certificate to your iOS platform and that the platform mode matches that certificate.

## Setup

Begin by cloning the repo and using the closest release that matches your PCF installation.

`git clone git@github.com:cfmobile/push-ios-heartbeatmonitor.git`

There are two files that you will need to modify:

1. Open PCF Push Heartbeat Monitor.xcodeproj in XCode

1. In the Project Navigator, select the Info.plist file

1. Change the App Transport Security Settings > Exception Domains dictionary by replacing `push-api.your.env.com` with your push-api url

1. In the Project Navigator, select the Pivotal.plist file

1. Change the pivotal.push.serviceUrl field by replacing `push-api.your.env.com` with your push-api url
    - __Note:__ Ensure the platform UUID and platform secret match the iOS platform found in your Configuration tab on your Push Dashboard _(They should by default)_

1. Build the Heartbeat Monitor on an iOS 8.0+ device

1. Accept Push Notifications on the device

1. Ensure the device shows up in the Devices tab of your iOS Platform on your Push Dashboard
