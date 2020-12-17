# Entwined iOS App

This app should be delivered on as few devices as possible (ideally, only the iPad that goes with the installation), to ensure that there's no conflict between multiple users of the app.

**Authorized devices can install/update the app by going to [http://charliestigler.com/entwined-ios/](http://charliestigler.com/entwined-ios/)**

## iOS App Installation and Use
* Make sure iOS device is listed in the Entwined Ad-Hoc Distribution provisioning profile (contact Charlie S to add a device)
* Connect iOS device to internet 
* Install Entwined app by [clicking here](http://charliestigler.com/entwined-ios/) on the device
* Make sure installation is powered on and WiFi is active 
* Open Settings -> WiFi on iPad and connect to Entwined WiFi
* Open app and click the *Connecting to Entwined Meadow* text at the bottom of the screen to set the proper server hostname, if it doesn't find it automatically.
* Click *Start Controlling* to start interacting with the trees

## How to build iOS App from source

## Pre-reqs
* Xcode
* Apple Developer Account (free version is fine) 
* Github.com account
* Install CocoaPods (Xcode library dependencies) https://guides.cocoapods.org/using/getting-started.html

## Installation Instructions
* Download source code from github
  * cd ~/Desktop; git clone ; https://github.com/cstigler/entwined-ios.git
* Install latest dependencies:
  * cd ~/Desktop/entwined-ios; pod install ; pod update;
* Add your developer Apple ID to Xcode and make a cert
  * Open Xcode
  * Go to Xcode->Preferences, and click on Accounts
  * Add your Apple ID	             	  
  * Create iOS Development Certificate:
  * Click on 'Manage Certificates"
  * Add iOS Development Certificate	 
* Open Entwined-iOS project in Xcode
  * File->Open
  * Navigate to entwined-ios dir
  * Open Entwined-iOS.xcworkspace
  * Connect to the iPad in the Build pulldown
  * Click top left arrow to "build" Entwined
  * If build succeeds, then connect ipad to computer
  * Go to top left header and set Device to new iPad
  * Click Build again
  * Check app is built on iPad
  * Sometimes iPad will say "Third-Party Apps from Unidentified Developers cannot be opened"
  * In this case, go to Settings > General > Profiles or Profiles & Device Management and click on developer name and hit Trust

NOTE: if you build the app yourself, you are creating a debug build that will install and run on any iOS device.  BUT because it is not a trusted app, after 30 days, the build will stop working on the device and will just refuse to open. For production use, always install using the Ad-Hoc Distributionb uildbuild.

