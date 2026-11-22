// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "About",
  defaultLocalization: "id",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "About", targets: ["About"])
  ],
  dependencies: [
    .package(path: "../Common")
  ],
  targets: [
    .target(
      name: "About",
      dependencies: [
        .product(name: "Common", package: "Common")
      ]
    ),
    .testTarget(name: "AboutTests", dependencies: ["About"])
  ]
)
