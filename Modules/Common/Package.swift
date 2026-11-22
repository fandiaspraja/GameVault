// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Common",
  defaultLocalization: "id",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "Common", targets: ["Common"])
  ],
  dependencies: [
    .package(url: "https://github.com/fandiaspraja/GameVaultCore.git", from: "1.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0")
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "Kingfisher", package: "Kingfisher")
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "CommonTests",
      dependencies: [
        "Common",
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Alamofire", package: "Alamofire")
      ]
    )
  ]
)
