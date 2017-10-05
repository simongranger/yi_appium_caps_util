Gem::Specification.new do |s|
  s.name        = 'yi_appium_caps_util'
  s.version     = '1.0.4'
  s.executables << 'yi_appium_caps_util'
  s.date        = '2017-10-05'
  s.summary     = "Updates your appium.txt capabilities for iOS and Android"
  s.description = "This utility updates the caps for iOS and Android devices. Please refer to homepage for ruther details on usage"
  s.authors     = ["Simon Granger","Mohamed Maamoun", "Tamimi Ahmad"]
  s.email       = 'simon.granger@youi.tv'
  s.files       = ["lib/yi_appium_caps_util.rb", "app/getIOSIP.zip"]
  s.homepage    =
    'https://github.com/YOU-i-Labs/yi_appium_caps_util'
  s.license       = 'MIT'
  s.add_runtime_dependency 'ipaddress', '~> 0.8.3'
  s.add_runtime_dependency 'toml', '~> 0.1.2'
end
