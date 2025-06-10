// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SeatclubApp",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "SeatclubApp", targets: ["SeatclubApp"])
    ],
    targets: [
        .binaryTarget(
            name: "SeatclubApp",
            url: "https://github.com/Seatclub-Scope/seatclub-widget/releases/download/1.0.0/SeatclubApp.xcframework.zip",
            checksum: "your-checksum-here"
        )
    ]
)