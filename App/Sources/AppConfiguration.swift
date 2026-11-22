//
//  AppConfiguration.swift
//  GameVault
//

import About
import Foundation

enum AppConfiguration {
  /// API key RAWG dibaca dari Info.plist, yang diisi dari Config/Secrets.xcconfig
  /// (file tersebut tidak di-push ke GitHub).
  static var rawgAPIKey: String {
    let value = Bundle.main.object(forInfoDictionaryKey: "RAWG_API_KEY") as? String ?? ""
    return value.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  static var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
  }
}

extension Profile {
  /// Biodata pembuat aplikasi (wajib nama & foto asli).
  static let owner = Profile(
    name: "Fikry Andias Praja",
    role: "iOS Developer · Dicoding Academy",
    email: "fandiaspraja@gmail.com",
    city: "Subang, Indonesia",
    course: "Menjadi iOS Developer Expert",
    photoAssetName: "profile_photo"
  )
}
