//
//  AppFormatter.swift
//  Common
//

import Foundation

/// Format tampilan (tanggal, rating, angka) mengikuti bahasa aplikasi.
public enum AppFormatter {
  /// Contoh: 17 Sep 2013 (id) atau Sep 17, 2013 (en). "TBA" bila belum diumumkan.
  public static func date(_ date: Date?) -> String {
    guard let date else { return L10n.General.tba }
    let formatter = DateFormatter()
    formatter.locale = L10n.locale
    formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
    return formatter.string(from: date)
  }

  /// Contoh: 4,47 (id) atau 4.47 (en).
  public static func rating(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = L10n.locale
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
  }

  /// Contoh: 6.712 (id) atau 6,712 (en).
  public static func count(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.locale = L10n.locale
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
  }
}

/// Parser tanggal format API RAWG ("yyyy-MM-dd").
public enum APIDate {
  private static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  public static func parse(_ value: String?) -> Date? {
    guard let value, !value.isEmpty else { return nil }
    return formatter.date(from: value)
  }

  public static func string(from date: Date?) -> String? {
    date.map { formatter.string(from: $0) }
  }
}

public extension URL {
  /// Versi gambar RAWG yang sudah di-crop (lebih ringan untuk thumbnail).
  func rawgResized(width: Int = 600, height: Int = 400) -> URL {
    let value = absoluteString
    guard value.contains("media.rawg.io/media/"), !value.contains("/media/crop/") else { return self }
    let resized = value.replacingOccurrences(of: "/media/", with: "/media/crop/\(width)/\(height)/")
    return URL(string: resized) ?? self
  }
}

/// Nilai navigasi ke halaman detail. Yang dikirim cukup ID gim.
public struct GameRoute: Hashable {
  public let id: Int

  public init(id: Int) {
    self.id = id
  }
}
