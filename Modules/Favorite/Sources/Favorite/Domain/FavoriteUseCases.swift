//
//  FavoriteUseCases.swift
//  Favorite
//
//  Use case favorit. Semuanya memenuhi protokol generik `UseCase` dari GameVaultCore.
//

import Combine
import Foundation
import GameVaultCore

/// Mengambil seluruh gim favorit (terbaru di atas).
public struct GetFavoritesInteractor<Repo: FavoriteRepositoryProtocol>: UseCase {
  private let repository: Repo

  public init(repository: Repo) {
    self.repository = repository
  }

  public func execute(request: Void?) -> AnyPublisher<[FavoriteGame], Error> {
    repository.getFavorites()
  }
}

/// Mengecek apakah sebuah gim sudah ada di favorit.
public struct CheckFavoriteInteractor<Repo: FavoriteRepositoryProtocol>: UseCase {
  private let repository: Repo

  public init(repository: Repo) {
    self.repository = repository
  }

  public func execute(request id: Int?) -> AnyPublisher<Bool, Error> {
    guard let id else {
      return Fail(error: CoreError.invalidRequest).eraseToAnyPublisher()
    }
    return repository.isFavorite(id: id)
  }
}

/// Menambah gim ke favorit bila belum ada, atau menghapusnya bila sudah ada.
/// Menghasilkan status favorit yang baru (`true` = tersimpan).
public struct ToggleFavoriteInteractor<Repo: FavoriteRepositoryProtocol>: UseCase {
  private let repository: Repo

  public init(repository: Repo) {
    self.repository = repository
  }

  public func execute(request game: FavoriteGame?) -> AnyPublisher<Bool, Error> {
    guard let game else {
      return Fail(error: CoreError.invalidRequest).eraseToAnyPublisher()
    }
    let repository = self.repository
    return repository.isFavorite(id: game.id)
      .flatMap { isFavorite -> AnyPublisher<Bool, Error> in
        if isFavorite {
          return repository.remove(id: game.id).map { _ in false }.eraseToAnyPublisher()
        }
        return repository.add(game).map { _ in true }.eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
}

/// Menghapus gim dari favorit.
public struct RemoveFavoriteInteractor<Repo: FavoriteRepositoryProtocol>: UseCase {
  private let repository: Repo

  public init(repository: Repo) {
    self.repository = repository
  }

  public func execute(request id: Int?) -> AnyPublisher<Bool, Error> {
    guard let id else {
      return Fail(error: CoreError.invalidRequest).eraseToAnyPublisher()
    }
    return repository.remove(id: id)
  }
}
