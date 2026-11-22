//
//  GameModels.swift
//  Game
//

import Foundation

/// Model domain gim pada daftar Beranda.
public struct GameModel: Identifiable, Equatable, Hashable {
  public let id: Int
  public let name: String
  public let imageURL: URL?
  public let rating: Double
  public let releaseDate: Date?
  public let genre: String?
}

/// Satu halaman hasil daftar gim.
public struct GamePage: Equatable {
  public let games: [GameModel]
  public let hasNextPage: Bool

  public init(games: [GameModel], hasNextPage: Bool) {
    self.games = games
    self.hasNextPage = hasNextPage
  }
}

public struct GenreModel: Identifiable, Equatable, Hashable {
  public let id: Int
  public let name: String
  public let slug: String

  public init(id: Int, name: String, slug: String) {
    self.id = id
    self.name = name
    self.slug = slug
  }
}
