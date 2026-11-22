//
//  FavoriteMappers.swift
//  Favorite
//

import Common
import Foundation
import GameVaultCore

/// Entity (Data) -> Model (Domain)
public struct FavoriteEntityToDomainMapper: Mapper {
  public init() {}

  public func transform(_ input: FavoriteGameEntity) -> FavoriteGame {
    FavoriteGame(
      id: input.id,
      name: input.name,
      imageURL: input.imageURL.flatMap(URL.init(string:)),
      rating: input.rating,
      releaseDate: APIDate.parse(input.released),
      genre: input.genre
    )
  }
}

/// Model (Domain) -> Entity (Data)
public struct FavoriteDomainToEntityMapper: Mapper {
  private let now: () -> Date

  public init(now: @escaping () -> Date = Date.init) {
    self.now = now
  }

  public func transform(_ input: FavoriteGame) -> FavoriteGameEntity {
    FavoriteGameEntity(
      id: input.id,
      name: input.name,
      imageURL: input.imageURL?.absoluteString,
      rating: input.rating,
      released: APIDate.string(from: input.releaseDate),
      genre: input.genre,
      addedAt: now()
    )
  }
}
