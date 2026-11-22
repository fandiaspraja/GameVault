// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "Detail",
  defaultLocalization: "id",
  platforms: [.iOS(.v16)],
  products: [
    .library(name: "Detail", targets: ["Detail"])
  ],
  dependencies: [
    .package(url: "https://github.com/fandiaspraja/GameVaultCore.git", from: "1.0.0"),
    .package(path: "../Common"),
    .package(path: "../Favorite")
  ],
  targets: [
    .target(
      name: "Detail",
      dependencies: [
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Common", package: "Common"),
        .product(name: "Favorite", package: "Favorite")
      ]
    ),
    .testTarget(
      name: "DetailTests",
      dependencies: [
        "Detail",
        .product(name: "GameVaultCore", package: "GameVaultCore"),
        .product(name: "Favorite", package: "Favorite")
      ]
    )
  ]
)
