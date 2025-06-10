# SeatclubApp

A self-contained React Native framework for iOS that can be easily integrated into any iOS app.

## Installation

### CocoaPods

Add this line to your Podfile:

```ruby
pod 'SeatclubApp', :git => 'https://github.com/Seatclub-Scope/seatclub-widget.git', :tag => '1.0.0'
```

### Swift Package Manager

Add this to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/Seatclub-Scope/seatclub-widget.git", from: "1.0.0")
]
```

## Usage

### Swift/UIKit

```swift
import SeatclubApp

// Create a view controller
let seatclubApp = SeatclubApp()
let viewController = seatclubApp.createViewController(
    theme: "light",
    title: "Welcome to SeatClub!"
)

// Present it
present(viewController, animated: true)
```

### SwiftUI

```swift
import SeatclubApp

struct ContentView: View {
    var body: some View {
        SeatclubAppView(theme: "light", title: "Welcome!")
    }
}
```

### Objective-C

```objc
@import SeatclubApp;

UIViewController *vc = [SeatclubAppObjC createViewControllerWithTheme:@"light" title:@"Welcome!"];
[self presentViewController:vc animated:YES completion:nil];
```

## Development

### Prerequisites

- Node.js 16+
- React Native CLI
- Xcode 14+
- CocoaPods

### Building

1. Install dependencies:

   ```bash
   npm install
   ```

2. Build the framework:
   ```bash
   ./build-framework.sh
   ```

## License
