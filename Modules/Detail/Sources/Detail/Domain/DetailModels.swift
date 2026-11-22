//
//  DetailModels.swift
//  Detail
//

import Foundation

/// Model domain untuk halaman detail gim.
public struct GameDetailModel: Identifiable, Equatable {
  public static let longDescriptionThreshold = 220

  public let id: Int
  public let name: String
  public let about: String
  public let imageURL: URL?
  public let rating: Double
  public let ratingsCount: Int
  public let releaseDate: Date?
  public let metacritic: Int?
  public let playtime: Int
  public let website: URL?
  public let genres: [String]
  public let platforms: [String]
  public let developers: [String]

  /// Deskripsi perlu tombol "Baca selengkapnya".
  public var hasLongDescription: Bool {
    about.count > Self.longDescriptionThreshold
  }

  public var primaryDeveloper: String? {
    developers.first
  }
}

/// Tingkat skor Metacritic (≥ 75 hijau, 50–74 kuning, < 50 merah).
public enum MetascoreLevel: Equatable {
  case favorable
  case mixed
  case unfavorable

  public init(score: Int) {
    switch score {
    case 75...: self = .favorable
    case 50..<75: self = .mixed
    default: self = .unfavorable
    }
  }
}

/// Screenshot gim (fitur tambahan submission akhir: galeri di halaman detail).
public struct ScreenshotModel: Identifiable, Equatable, Hashable {
  public let id: Int
  public let imageURL: URL

  public init(id: Int, imageURL: URL) {
    self.id = id
    self.imageURL = imageURL
  }
}
