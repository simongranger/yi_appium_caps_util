[![Gem Version](https://badge.fury.io/rb/yi_appium_caps_util.svg)](https://badge.fury.io/rb/yi_appium_caps_util)
# yi_appium_caps_util

This gem is meant to help create and/or update the appium.txt file. Note that a prerequisite to using this gem is to have the device connected to the machine.

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
youiEngineAppAddress will be updated using `getiOSIP.app`

## macOS ##
### youiEngineAppAddress ###
youiEngineAppAddress will be set to `localhost`

## tvOS ##
### youiEngineAppAddress ###
youiEngineAppAddress will be updated using `getiOSIP.app`


# How to Use #

## Dependencies Installation ##
  $ brew install libimobiledevice

  $ brew install ios-deploy

  $ gem install ipaddress

  $ gem install toml

## Installation ##
  $ gem install yi_appium_caps_util  

## Running ##
* `yi_appium_caps_util -u` if appium.txt is in your local folder
* `yi_appium_caps_util -u -f *path/file*` to define the path/filename
* `yi_appium_caps_util -c platform` to create the appium.txt file.
