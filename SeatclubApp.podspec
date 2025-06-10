Pod::Spec.new do |s|
  s.name             = 'SeatclubApp'
  s.version          = '1.0.2'
  s.summary          = 'SeatclubApp React Native Framework'
  s.description      = 'A self-contained React Native framework for SeatClub functionality that can be easily integrated into any iOS app'
  s.homepage         = 'https://github.com/Seatclub-Scope/seatclub-snap-widget'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taylor Conlin' => 'taylor@scopelabs.com' }
  s.source           = { :git => 'https://github.com/Seatclub-Scope/seatclub-snap-widget.git', :tag => s.version.to_s }

  s.ios.deployment_target = '17.0'

  # Only include Swift source files, not Xcode project files
  s.source_files = 'ios/SeatclubApp/SeatclubApp/SeatclubApp/*.swift'
  
  # Include the header file
  s.public_header_files = 'ios/SeatclubApp/SeatclubApp/SeatclubApp/*.h'
  
  # JavaScript bundle and assets as resources
  s.resources = ['ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle']

  # No React Native dependencies - completely self-contained
  s.frameworks = 'JavaScriptCore'

  # Remove the problematic script phase for now
  # s.script_phase = {
  #   :name => 'Bundle SeatclubApp',
  #   :script => 'cd "${PODS_TARGET_SRCROOT}" && if [ -f "build-bundle.sh" ]; then echo "Building SeatclubApp JS bundle..." && ./build-bundle.sh; else echo "Warning: build-bundle.sh not found"; fi',
  #   :execution_position => :before_compile
  # }
end
