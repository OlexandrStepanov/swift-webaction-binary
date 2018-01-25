// swift-tools-version:3.1.0

import PackageDescription

let package = Package(
    name: "Action",
    targets: [
        Target(name: "Utilities"),
        Target(name: "Time", dependencies: ["Utilities"])
    ],
    dependencies: [
    ]
)
