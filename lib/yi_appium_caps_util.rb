require "ipaddress"
require 'socket'
require 'toml'

class YiAppiumCapsUtil
  class << self
    public
    def update (caps_file_name = './appium.txt')
      raise "appium.txt file is missing" if not File.file?(caps_file_name)

      #Read capability file
      parsed_data = TOML.load_file(caps_file_name)

      #Update caps
      output_data = run_update(parsed_data)

      #Save the file if caps have changed
      if (output_data != parsed_data)
        puts 'Updating caps'
        write_caps(caps_file_name, output_data)
      else
        puts 'caps have not changed'
      end
    end

    def create (platform_name)
      File.open("./appium.txt","w") do |f|
        f.puts("[caps]\napp = \" \"\nautomationName = \"YouiEngine\"\ndeviceName = \" \"\nplatformName = \"#{platform_name}\"\nyouiEngineAppAddress = \" \"\n")
      end
      update()
    end

    private

    def run_update(parsed_data)
      #Make a copy of the parsed data
      output_data = Marshal.load(Marshal.dump(parsed_data))

      if parsed_data['caps'] == nil
        raise '[caps] is missing form appium.txt'
      else
        platformName_value = parsed_data['caps']['platformName']

        if platformName_value == nil
          raise 'platformName is missing from appium.txt'
        else
          case platformName_value.downcase
          when 'android'
            update_android_caps (output_data)
          when 'ios'
            update_ios_caps (output_data)
          else
            raise 'platformName: ' + platformName_value + ' is not supported'
          end
        end
      end
      return output_data
    end

    def update_android_caps (output_data)
      puts 'Looking for Android device'
      #Get the device name
      new_device_name = `adb devices | grep -w "device" | awk -F'\tdevice' '{print $1}'`
      #Remove whitespace
      new_device_name = new_device_name.strip
      raise "No Devices found / attached. If it is connected then check that it USB debugging is allowed and access to usb debugging for this machine is granted." if new_device_name == ''
      #Replace value of deviceName
      output_data['caps']['deviceName'] = new_device_name
      puts 'Device ID: ' +  new_device_name

      #Get the device's ip address and mask
      address_String = `adb shell ifconfig wlan0 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'`
      raise "Cannot get device details. Check that it USB debugging is authorized." if !$?.success?
      #Split IP from mask
      new_address = address_String.split("\n")
      #Replace value of youiEngineAppAddress
      output_data['caps']['youiEngineAppAddress'] = new_address[0]
      puts 'IP address: ' + new_address[0]
    rescue RuntimeError => ex
      puts ex.message
      raise
    rescue Exception => ex
      puts "An error of type #{ex.class} happened, message is #{ex.message}"
      raise
    end

    def update_ios_caps (output_data)
      puts 'Looking for iOS device'
      #Get the device UDID
      new_udid = %x[idevice_id -l]
      #Remove whitespace
      new_udid = new_udid.strip

      raise "No Devices found / attached." if (new_udid == '')

      #Replace value of udid
      output_data['caps']['udid'] = new_udid
      puts 'udid: ' + new_udid

      if (output_data['caps']['skipYouiEngineAppAddress'] != nil)
        puts
        puts 'Skiping IP check since skipYouiEngineAppAddress is present in appium.txt'
      else
        puts 'Searching for IP, this may take a few seconds...'

        #https://github.com/LorneFlindall/getIP
        myAppFolder = File.dirname(__FILE__) + "/../app/"
        myApp = myAppFolder + "getIP.app"
        myZipApp = myAppFolder + "getIP.app.zip"
        %x[unzip -o #{myZipApp} -d #{myAppFolder}]

        puts "Launching getIP app"
        #Launching app and putting (5 seconds of) log into file
        ipcounter = 1
        while ipcounter <= 5 do
          puts "Try \# #{ipcounter}"
          iplog = %x[ios-deploy --justlaunch --bundle #{myApp} & (idevicesyslog) & sleep 5 ; kill $!]
          File.write('iplog.txt', iplog)
          #Getting ip from file
          ip = %x[grep -m1 'IPAddress:' iplog.txt | awk '{print $8}']
          #Remove whitespace
          ip = ip.strip
          puts 'IP Address: ' + ip
          if (ip == "")
            ipcounter +=1
          else
            #Found it!  
            ipcounter = 999
          end
        end
        File.delete('iplog.txt')
        #Replace value of udid
        output_data['caps']['youiEngineAppAddress'] = ip
    end

    rescue Exception => ex
      puts "An error of type #{ex.class} happened, message is #{ex.message}"
      exit
    end

    def write_caps(caps_file_name, output_data)
      #Write the new caps to file
      doc = TOML::Generator.new(output_data).body
      File.open(caps_file_name, "w") {|file| file.puts doc }
    end
  end
end
