//
//  Profile.swift
//  About
//

import Foundation

/// Biodata pembuat aplikasi. Datanya disuntikkan dari aplikasi utama.
public struct Profile: Equatable {
  public let name: String
  public let role: String
  public let email: String
  public let city: String
  public let course: String
  /// Nama asset foto di Assets.xcassets milik aplikasi utama.
  public let photoAssetName: String

  public init(name: String, role: String, email: String, city: String, course: String, photoAssetName: String) {
    self.name = name
    self.role = role
    self.email = email
    self.city = city
    self.course = course
    self.photoAssetName = photoAssetName
  }

  /// Inisial nama, dipakai bila foto gagal dimuat.
  public var initials: String {
    name.split(separator: " ")
      .prefix(2)
      .compactMap(\.first)
      .map { String($0).uppercased() }
      .joined()
  }

  public var emailURL: URL? {
    URL(string: "mailto:\(email)")
  }
}
