//
//  GameResponses.swift
//  Game
//
//  Model respons API RAWG. Hampir semua properti optional karena beberapa
//  hasil (mis. pencarian "Naruto") mengandung nilai null.
//

import Foundation

public struct GameListResponse: Decodable {
  public let next: String?
  public let results: [GameResponse]
}

public struct GameResponse: Decodable {
  public let id: Int
  public let name: String?
  public let backgroundImage: String?
  public let rating: Double?
  public let released: String?
  public let genres: [GenreResponse]?
}

public struct GenreListResponse: Decodable {
  public let results: [GenreResponse]
}

public struct GenreResponse: Decodable {
  public let id: Int
  public let name: String?
  public let slug: String?
}
