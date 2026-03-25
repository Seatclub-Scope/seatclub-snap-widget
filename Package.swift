// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SeatclubApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SeatclubApp", targets: ["SeatclubApp"])
    ],
    targets: [
        // TODO: Upload SeatclubApp.xcframework.zip to the 1.0.3 release and update the checksum.
        // Run: swift package compute-checksum SeatclubApp.xcframework.zip
        .binaryTarget(
            name: "SeatclubApp",
            url: "https://github.com/Seatclub-Scope/seatclub-snap-widget/releases/download/1.0.3/SeatclubApp.xcframework.zip",
            checksum: "b404dbf63181b42aa255e8669c6baf3e3e132e97b5afe2b0a8ce4e23c26840c1"
        )
    ]
)
