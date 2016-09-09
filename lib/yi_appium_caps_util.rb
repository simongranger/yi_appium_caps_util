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
        #get mac address of iOS device
        mac_address = %x[ideviceinfo -k WiFiAddress]

        #prepare string
        raise "Could not retrieve device Information. Make sure that this computer is trusted by the device." if !$?.success?
        mac_address.gsub!(/0([[:alnum:]])/, '0?\1')
        mac_address.gsub!("\n","")

        $ip_address_string = ""
        #Check arp cache first
        puts "Looking in arp cache first"
        $ip_address_string = %x[arp -na | egrep #{mac_address}]
        if ($ip_address_string == "")
          puts "Device not in arp cache."

          begin
            broadcast_ip = %x[ifconfig].scan(/broadcast ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/)

            puts "Sending broadcast on your connected network. This assumes that your device is on the same local network as this computer."
            subnets = []
            broadcast_ip.uniq.each do |addr|
              puts "Sending broadcast to " + addr[0].to_s
              temp_subnets = %x[ping -c 10  #{addr[0].to_s}]
              subnets += temp_subnets.scan(/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\.[0-9]{1,3}/).uniq
            end
            puts "Broadcast done"
          rescue Exception => ex
            puts "Skipping ping broadcast."
          end

          begin
            nmap_available = %x[nmap -h]
            puts "Forcing ARP to refresh. This assumes that your device is on the same local network as this computer."
            subnets.uniq.each do |ip|
              puts "Sending nmap broadcast on " + ip[0].to_s
              %x[nmap -sP #{ip[0].to_s}0/24]

              $ip_address_string = get_arp_table(mac_address)
              if ($ip_address_string != "")
                break
              end
            end
            puts "Nmap broadcast done"
          rescue Exception => ex
            puts "Skipping nmap broadcast. Nmap is not installed. It can be downloaded from: https://nmap.org/download.html"
            # Nmap not installed. Let's try arp before giving up
            $ip_address_string = get_arp_table(mac_address)
          end

          raise "Could not retrieve IP. Please ensure that:\n1) Device is set to never sleep (General Settings-> Auto-Lock-> Never.\n2) Device is on the same network as this computer." if $ip_address_string == ""
        end

        #extract ip from string
        new_ip_address = IPAddress::IPv4::extract $ip_address_string
        #Replace value of udid
        output_data['caps']['youiEngineAppAddress'] = new_ip_address.to_s
        puts 'IP Address: ' + new_ip_address.to_s
      end

    rescue Exception => ex
      puts "An error of type #{ex.class} happened, message is #{ex.message}"
      exit
    end

    def get_arp_table(mac_address)

      $i = 1
      $num = 5
      puts Time.now.strftime("%Y-%m-%d %H:%M:%S") + " Trying to get arp table. Try " + $i.to_s
      begin
        ip_address_string = %x[arp -a | egrep #{mac_address}]
        $i +=1
        raise "" if (ip_address_string == "")
        return ip_address_string
      rescue
        if ($i <= $num)
          sleep_increment = 15
          sleep_time = sleep_increment*(1)
          puts Time.now.strftime("%Y-%m-%d %H:%M:%S") + " Try "+ $i.to_s + ". Sleeping " + sleep_time.to_s + " seconds before next arp attempt."
          sleep sleep_time
          retry
        else

          return ""

        end
      end
    end

    def write_caps(caps_file_name, output_data)
      #Write the new caps to file
      doc = TOML::Generator.new(output_data).body
      File.open(caps_file_name, "w") {|file| file.puts doc }
    end
  end
end
