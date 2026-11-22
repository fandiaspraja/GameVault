// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Favorite",
  defaultLocalization: "id",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "Favorite", targets: ["Favorite"])
  ],
  dependencies: [
    .package(url: "https://github.com/fandiaspraja/GameVaultCore.git", from: "1.0.0"),
    .package(path: "../Common")
  ],
  targets: [
    .target(
      name: "Favorite",
      dependencies: [
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Common", package: "Common")
      ]
    ),
    .testTarget(
      name: "FavoriteTests",
      dependencies: [
        "Favorite",
        .product(name: "GameVaultCore", package: "GameVaultCore")
      ]
    )
  ]
)
