// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Game",
  defaultLocalization: "id",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "Game", targets: ["Game"])
  ],
  dependencies: [
    .package(url: "https://github.com/fandiaspraja/GameVaultCore.git", from: "1.0.0"),
    .package(path: "../Common")
  ],
  targets: [
    .target(
      name: "Game",
      dependencies: [
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Common", package: "Common")
      ]
    ),
    .testTarget(
      name: "GameTests",
      dependencies: [
        "Game",
        .product(name: "GameVaultCore", package: "GameVaultCore")
      ]
    )
  ]
)
