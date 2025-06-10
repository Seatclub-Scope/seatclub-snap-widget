Pod::Spec.new do |s|
    s.name             = 'SeatclubApp'
    s.version          = '1.0.0'
    s.summary          = 'SeatclubApp React Native Framework'
    s.description      = 'A self-contained React Native framework for SeatClub functionality that can be easily integrated into any iOS app'
    s.homepage         = 'https://github.com/yourorg/seatclub-app'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Taylor Conlin' => 'taylor@scopelabs.com' }
    s.source           = { :git => 'https://github.com/Seatclub-Scope/seatclub-widget', :tag => s.version.to_s }
  
    s.ios.deployment_target = '17.0'
  
    # Swift source files
    s.source_files = 'ios/SeatclubApp/SeatclubApp/**/*'
    
    # JavaScript bundle and assets
    s.resource_bundles = {
      'SeatclubApp' => ['ios/SeatclubApp/SeatclubApp/seatclub-app.jsbundle', 'ios/SeatclubApp/SeatclubApp/assets/*']
    }
  
    # No React Native dependencies - completely self-contained
    s.frameworks = 'JavaScriptCore'
  
    # Build the JS bundle during pod install
    s.script_phase = {
      :name => 'Bundle SeatclubApp',
      :script => 'cd "${PODS_TARGET_SRCROOT}" && if [ -f "build-bundle.sh" ]; then echo "Building SeatclubApp JS bundle..." && ./build-bundle.sh; else echo "Warning: build-bundle.sh not found"; fi',
      :execution_position => :before_compile
    }
  end