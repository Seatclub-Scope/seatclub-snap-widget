Pod::Spec.new do |s|
  s.name             = 'SeatclubApp'
  s.version          = '1.0.3'
  s.summary          = 'SeatclubApp React Native Framework'
  s.description      = 'A self-contained React Native framework for SeatClub functionality that can be easily integrated into any iOS app'
  s.homepage         = 'https://github.com/Seatclub-Scope/seatclub-snap-widget'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SeatClub' => 'contact@seatclub.com' }
  s.source           = { :git => 'https://github.com/Seatclub-Scope/seatclub-snap-widget.git', :tag => s.version.to_s }

  s.ios.deployment_target = '17.0'
  s.swift_version = '5.0'

  # Source files
  s.source_files = 'ios/SeatclubApp/SeatclubApp/SeatclubApp/*.{swift,h}'
  
  # Pre-built JavaScript bundle
  s.resources = ['ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle']

  # Dependencies
  s.frameworks = 'JavaScriptCore'
end
