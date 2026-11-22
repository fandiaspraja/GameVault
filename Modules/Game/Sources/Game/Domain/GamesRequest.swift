//
//  GamesRequest.swift
//  Game
//
//  Aturan bisnis untuk permintaan daftar gim (dibuat dengan pendekatan TDD,
//  lihat GamesRequestTests).
//

import Foundation

/// Pilihan urutan daftar gim (fitur tambahan submission akhir).
public enum GameOrdering: String, CaseIterable, Identifiable {
  case relevance
  case popular
  case rating
  case newest
  case name

  public var id: String { rawValue }

  /// Nilai parameter `ordering` untuk API RAWG. `nil` = urutan bawaan (relevansi).
  public var apiValue: String? {
    switch self {
    case .relevance: return nil
    case .popular: return "-added"
    case .rating: return "-rating"
    case .newest: return "-released"
    case .name: return "name"
    }
  }
}

public struct GamesRequest: Equatable {
  public static let defaultPageSize = 20
  public static let maxPageSize = 40

  public let page: Int
  public let query: String?
  public let genreSlug: String?
  public let ordering: GameOrdering
  public let pageSize: Int

  public init(
    page: Int = 1,
    query: String? = nil,
    genreSlug: String? = nil,
    ordering: GameOrdering = .relevance,
    pageSize: Int = GamesRequest.defaultPageSize
  ) {
    self.page = max(page, 1)
    self.query = Self.normalize(query)
    self.genreSlug = Self.normalize(genreSlug)
    self.ordering = ordering
    self.pageSize = min(max(pageSize, 1), Self.maxPageSize)
  }

  /// Permintaan untuk halaman berikutnya dengan filter yang sama.
  public func nextPage() -> GamesRequest {
    GamesRequest(page: page + 1, query: query, genreSlug: genreSlug, ordering: ordering, pageSize: pageSize)
  }

  public var isSearching: Bool {
    query != nil
  }

  private static func normalize(_ value: String?) -> String? {
    let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return trimmed.isEmpty ? nil : trimmed
  }
}

public extension Array where Element == GameModel {
  /// Menggabungkan halaman baru tanpa duplikasi (RAWG kadang mengulang item antarhalaman).
  func appendingUnique(_ newGames: [GameModel]) -> [GameModel] {
    var seen = Set(map(\.id))
    return self + newGames.filter { seen.insert($0.id).inserted }
  }
}
