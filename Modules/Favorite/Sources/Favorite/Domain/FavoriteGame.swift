//
//  FavoriteGame.swift
//  Favorite
//

import Foundation

/// Model domain gim favorit.
public struct FavoriteGame: Identifiable, Equatable, Hashable {
  public let id: Int
  public let name: String
  public let imageURL: URL?
  public let rating: Double
  public let releaseDate: Date?
  public let genre: String?

  public init(id: Int, name: String, imageURL: URL?, rating: Double, releaseDate: Date?, genre: String?) {
    self.id = id
    self.name = name
    self.imageURL = imageURL
    self.rating = rating
    self.releaseDate = releaseDate
    self.genre = genre
  }
}
