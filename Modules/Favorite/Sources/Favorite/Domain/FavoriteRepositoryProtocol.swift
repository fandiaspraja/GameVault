//
//  FavoriteRepositoryProtocol.swift
//  Favorite
//

import Combine
import Foundation

/// Kontrak repository favorit milik Domain Layer (implementasinya di Data Layer).
public protocol FavoriteRepositoryProtocol {
  func getFavorites() -> AnyPublisher<[FavoriteGame], Error>
  func isFavorite(id: Int) -> AnyPublisher<Bool, Error>
  func add(_ game: FavoriteGame) -> AnyPublisher<Bool, Error>
  func remove(id: Int) -> AnyPublisher<Bool, Error>
}
