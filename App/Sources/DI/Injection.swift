//
//  Injection.swift
//  GameVault
//
//  Composition root. Semua objek dari modul Core, Common, Game, Detail,
//  dan Favorite dibuat & dirangkai di sini menggunakan Swinject.
//

import Common
import Detail
import Favorite
import Foundation
import Game
import GameVaultCore
import Swinject

final class Injection {
  static let shared = Injection()

  private let assembler: Assembler

  var resolver: Resolver {
    assembler.resolver
  }

  init(apiKey: String = AppConfiguration.rawgAPIKey, inMemoryStore: Bool = false) {
    assembler = Assembler([
      CommonAssembly(apiKey: apiKey),
      GameAssembly(),
      DetailAssembly(),
      FavoriteAssembly(inMemoryStore: inMemoryStore)
    ])
  }
}

enum ServiceName {
  static let checkFavorite = "checkFavorite"
  static let removeFavorite = "removeFavorite"
}

// MARK: - Common

struct CommonAssembly: Assembly {
  let apiKey: String

  func assemble(container: Container) {
    container.register(APIConfiguration.self) { _ in
      APIConfiguration(apiKey: apiKey)
    }
    .inObjectScope(.container)

    container.register(RAWGClient.self) { resolver in
      RAWGClient(configuration: resolver.resolveOrFail(APIConfiguration.self))
    }
    .inObjectScope(.container)
  }
}

// MARK: - Game (Beranda)

struct GameAssembly: Assembly {
  func assemble(container: Container) {
    container.register(AnyUseCase<GamesRequest, GamePage>.self) { resolver in
      let client = resolver.resolveOrFail(RAWGClient.self)
      let repository = RemoteRepository(remote: GamesRemoteDataSource(client: client), mapper: GamesMapper())
      return Interactor(repository: repository).eraseToAnyUseCase()
    }

    container.register(AnyUseCase<Void, [GenreModel]>.self) { resolver in
      let client = resolver.resolveOrFail(RAWGClient.self)
      let repository = RemoteRepository(remote: GenresRemoteDataSource(client: client), mapper: GenresMapper())
      return Interactor(repository: repository).eraseToAnyUseCase()
    }

    container.register(HomePresenter.self) { resolver in
      HomePresenter(
        getGames: resolver.resolveOrFail(AnyUseCase<GamesRequest, GamePage>.self),
        getGenres: resolver.resolveOrFail(AnyUseCase<Void, [GenreModel]>.self)
      )
    }
  }
}

// MARK: - Detail

struct DetailAssembly: Assembly {
  func assemble(container: Container) {
    container.register(AnyUseCase<Int, GameDetailModel>.self) { resolver in
      let client = resolver.resolveOrFail(RAWGClient.self)
      let repository = RemoteRepository(remote: GameDetailRemoteDataSource(client: client), mapper: GameDetailMapper())
      return Interactor(repository: repository).eraseToAnyUseCase()
    }

    container.register(AnyUseCase<Int, [ScreenshotModel]>.self) { resolver in
      let client = resolver.resolveOrFail(RAWGClient.self)
      let repository = RemoteRepository(remote: ScreenshotsRemoteDataSource(client: client), mapper: ScreenshotsMapper())
      return Interactor(repository: repository).eraseToAnyUseCase()
    }

    container.register(DetailPresenter.self) { (resolver: Resolver, gameId: Int) in
      DetailPresenter(
        gameId: gameId,
        getDetail: resolver.resolveOrFail(AnyUseCase<Int, GameDetailModel>.self),
        getScreenshots: resolver.resolveOrFail(AnyUseCase<Int, [ScreenshotModel]>.self),
        checkFavorite: resolver.resolveOrFail(AnyUseCase<Int, Bool>.self, name: ServiceName.checkFavorite),
        toggleFavorite: resolver.resolveOrFail(AnyUseCase<FavoriteGame, Bool>.self)
      )
    }
  }
}

// MARK: - Favorite

struct FavoriteAssembly: Assembly {
  let inMemoryStore: Bool

  func assemble(container: Container) {
    container.register(FavoriteStore.self) { _ in
      FavoriteStore(inMemory: inMemoryStore)
    }
    .inObjectScope(.container)

    container.register(FavoriteRepository<FavoriteLocalDataSource>.self) { resolver in
      FavoriteRepository(local: FavoriteLocalDataSource(store: resolver.resolveOrFail(FavoriteStore.self)))
    }
    .inObjectScope(.container)

    container.register(AnyUseCase<Void, [FavoriteGame]>.self) { resolver in
      GetFavoritesInteractor(repository: resolver.favoriteRepository).eraseToAnyUseCase()
    }

    container.register(AnyUseCase<Int, Bool>.self, name: ServiceName.checkFavorite) { resolver in
      CheckFavoriteInteractor(repository: resolver.favoriteRepository).eraseToAnyUseCase()
    }

    container.register(AnyUseCase<Int, Bool>.self, name: ServiceName.removeFavorite) { resolver in
      RemoveFavoriteInteractor(repository: resolver.favoriteRepository).eraseToAnyUseCase()
    }

    container.register(AnyUseCase<FavoriteGame, Bool>.self) { resolver in
      ToggleFavoriteInteractor(repository: resolver.favoriteRepository).eraseToAnyUseCase()
    }

    container.register(FavoritePresenter.self) { resolver in
      FavoritePresenter(
        getFavorites: resolver.resolveOrFail(AnyUseCase<Void, [FavoriteGame]>.self),
        removeFavorite: resolver.resolveOrFail(AnyUseCase<Int, Bool>.self, name: ServiceName.removeFavorite)
      )
    }
  }
}

// MARK: - Helper

extension Resolver {
  fileprivate var favoriteRepository: FavoriteRepository<FavoriteLocalDataSource> {
    resolveOrFail(FavoriteRepository<FavoriteLocalDataSource>.self)
  }

  func resolveOrFail<Service>(_ serviceType: Service.Type, name: String? = nil) -> Service {
    guard let service = resolve(serviceType, name: name) else {
      fatalError("Swinject: \(Service.self) (\(name ?? "-")) belum didaftarkan.")
    }
    return service
  }

  func resolveOrFail<Service, Arg>(_ serviceType: Service.Type, argument: Arg) -> Service {
    guard let service = resolve(serviceType, argument: argument) else {
      fatalError("Swinject: \(Service.self) dengan argumen \(Arg.self) belum didaftarkan.")
    }
    return service
  }
}
