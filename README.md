# yi_appium_caps_util

This gem is meant to help simplify the updating of your existing appium.txt files

# Supported platforms #

## Android ##
### deviceName ###
deviceName will be updated using `adb devices`
### youiEngineAppAddress ###
youiEngineAppAddress will be updated using `adb shell ifconfig wlan0`

## iOS ##
### udid ###
udid will be updated using `idevice_id -l`
### youiEngineAppAddress ###
youiEngineAppAddress will be updated using `getIP.app`

# How to Use #

## Dependencies Installation ##
  $ brew install libimobiledevice

  $ brew install ios-deploy

  $ gem install ipaddress

  $ gem install toml

## Installation ##
  $ gem install yi_appium_caps_util  

## Running ##
`yi_appium_caps_util -u` if appium.txt is in your local folder
`yi_appium_caps_util -u -f *path/file*` to define the path/filename
