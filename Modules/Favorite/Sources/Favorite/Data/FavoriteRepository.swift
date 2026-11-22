//
//  FavoriteRepository.swift
//  Favorite
//

import Combine
import Foundation
import GameVaultCore

/// Implementasi repository favorit, generik terhadap `LocalDataSource` mana pun
/// yang menyimpan `FavoriteGameEntity`.
public struct FavoriteRepository<Local: LocalDataSource>: FavoriteRepositoryProtocol
where Local.Request == Void, Local.Response == FavoriteGameEntity {
  private let local: Local
  private let toDomain: FavoriteEntityToDomainMapper
  private let toEntity: FavoriteDomainToEntityMapper

  public init(
    local: Local,
    toDomain: FavoriteEntityToDomainMapper = FavoriteEntityToDomainMapper(),
    toEntity: FavoriteDomainToEntityMapper = FavoriteDomainToEntityMapper()
  ) {
    self.local = local
    self.toDomain = toDomain
    self.toEntity = toEntity
  }

  public func getFavorites() -> AnyPublisher<[FavoriteGame], Error> {
    let mapper = toDomain
    return local.list(request: nil)
      .map { $0.map(mapper.transform) }
      .eraseToAnyPublisher()
  }

  public func isFavorite(id: Int) -> AnyPublisher<Bool, Error> {
    local.get(id: id)
      .map { $0 != nil }
      .eraseToAnyPublisher()
  }

  public func add(_ game: FavoriteGame) -> AnyPublisher<Bool, Error> {
    local.add(entity: toEntity.transform(game))
  }

  public func remove(id: Int) -> AnyPublisher<Bool, Error> {
    local.delete(id: id)
  }
}
