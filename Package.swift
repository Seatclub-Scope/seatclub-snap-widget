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
            url: "https://github.com/Seatclub-Scope/seatclub-snap-widget/releases/download/1.0.0/SeatclubApp.xcframework.zip",
            checksum: "820770af5c2780110cfc45729445dd3ba0904fc13eb6563f693f91f47a222b90"
        )
    ]
)
