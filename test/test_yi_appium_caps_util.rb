#!/usr/bin/env ruby
require "ipaddress"
require 'minitest/autorun'
require 'yi_appium_caps_util'

class YiAppiumCapsUtilTest < Minitest::Test

  def test_empty_file
    parsed_data = nil
    output_data = nil
    begin
      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
    rescue
      assert(true)
    else
      assert(false)
    end
  end

  def test_missing_caps
    parsed_data = {"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"",
      "youiEngineAppAddress"=>""}
    begin
      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
    rescue
      assert(true)
    else
      assert(false)
    end
  end

  def test_missing_platformName
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "youiEngineAppAddress"=>""}}

    begin
      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
    rescue
      assert(true)
    else
      assert(false)
    end
  end

  def test_empty_platformName
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"",
      "youiEngineAppAddress"=>""}}
    begin
      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
    rescue
      assert(true)
    else
      assert(false)
    end
  end

  def test_unsupported_platformName
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"foo",
      "youiEngineAppAddress"=>""}}
    begin
      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
    rescue
      assert(true)
    else
      assert(false)
    end
  end

  def test_android_all_empty
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"Android",
      "youiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(!(parsed_data['caps']['deviceName'].eql? output_data['caps']['deviceName']))
      assert(!(parsed_data['caps']['youiEngineAppAddress'].eql? output_data['caps']['youiEngineAppAddress']))
  end

  def test_android_missing_device
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "platformName"=>"Android",
      "youiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert_equal(parsed_data['caps']['deviceName'], nil)
      assert(output_data['caps']['deviceName'] != nil)
  end

  def test_android_missing_address
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"Android"}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert_equal(parsed_data['caps']['youiEngineAppAddress'], nil)
      assert(output_data['caps']['youiEngineAppAddress'] =! nil)
  end

  def test_android_valid_device_id
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"Android",
      "youiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(!(parsed_data['caps']['deviceName'].eql? output_data['caps']['deviceName']))
      assert(valid_device_id?(output_data['caps']['deviceName']))
    end

  def test_android_valid_ip
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"Android",
      "youiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(!(parsed_data['caps']['youiEngineAppAddress'].eql? output_data['caps']['youiEngineAppAddress']))
      assert(IPAddress.valid?(output_data['caps']['youiEngineAppAddress']))
  end

  def test_ios_missing_udid
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"iOS",
      "youiEngineAppAddress"=>"",
      "skipYouiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(parsed_data['caps']['udid'] == nil)
      assert(output_data['caps']['udid'] != nil)
  end

  def test_valid_udid
    bad_udid = '23413452345'
    good_udid = '360df367b7bc229d90889ddbf1fe48c245aca3fc'
    assert(!(valid_udid?(bad_udid)))
    assert(valid_udid?(good_udid))
  end

  def test_ios_valid_udid
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"iOS",
      "udid"=>"",
      "youiEngineAppAddress"=>"",
      "skipYouiEngineAppAddress"=>""}}

      output_data = results = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(!(parsed_data['caps']['udid'].eql? output_data['caps']['udid']))
      assert(valid_udid?(output_data['caps']['udid']))
  end

  def test_ios_valid_ip
    parsed_data = {"caps"=>{"app"=>"",
      "automationName"=>"",
      "deviceName"=>"",
      "platformName"=>"iOS",
      "udid"=>"",
      "youiEngineAppAddress"=>""}}

      output_data = YiAppiumCapsUtil.send(:run_update, parsed_data)
      assert(!(parsed_data['caps']['youiEngineAppAddress'].eql? output_data['caps']['youiEngineAppAddress']))
      assert(IPAddress.valid?(output_data['caps']['youiEngineAppAddress']))
  end

  def valid_udid?(udid)
    if /\b([a-f0-9]{40})\b/ =~ udid
      return true
    end
    return false
  end

  def valid_device_id?(device)
    if /[\w]+/ =~ device
      return true
    end
    return false
  end
end
