//
//  FavoriteTests.swift
//  FavoriteTests
//

import Combine
@testable import Favorite
import GameVaultCore
import XCTest

// MARK: - Test doubles & helpers

final class MockFavoriteRepository: FavoriteRepositoryProtocol {
  var stored: [FavoriteGame] = []
  var error: Error?
  private(set) var addCount = 0
  private(set) var removeCount = 0

  func getFavorites() -> AnyPublisher<[FavoriteGame], Error> { respond(stored) }
  func isFavorite(id: Int) -> AnyPublisher<Bool, Error> { respond(stored.contains { $0.id == id }) }

  func add(_ game: FavoriteGame) -> AnyPublisher<Bool, Error> {
    addCount += 1
    stored.append(game)
    return respond(true)
  }

  func remove(id: Int) -> AnyPublisher<Bool, Error> {
    removeCount += 1
    stored.removeAll { $0.id == id }
    return respond(true)
  }

  private func respond<T>(_ value: T) -> AnyPublisher<T, Error> {
    if let error { return Fail(error: error).eraseToAnyPublisher() }
    return Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
  }
}

enum Dummy {
  static func game(id: Int = 1, name: String = "Portal 2") -> FavoriteGame {
    FavoriteGame(
      id: id,
      name: name,
      imageURL: URL(string: "https://media.rawg.io/media/games/p2.jpg"),
      rating: 4.61,
      releaseDate: nil,
      genre: "Puzzle"
    )
  }
}

extension XCTestCase {
  func value<P: Publisher>(of publisher: P, timeout: TimeInterval = 2) throws -> P.Output {
    var result: Result<P.Output, Error>?
    let expectation = self.expectation(description: "publisher")
    let cancellable = publisher.sink { completion in
      if case .failure(let error) = completion { result = .failure(error) }
      expectation.fulfill()
    } receiveValue: { result = .success($0) }
    wait(for: [expectation], timeout: timeout)
    cancellable.cancel()
    return try XCTUnwrap(result).get()
  }

  func waitUntil(timeout: TimeInterval = 1, file: StaticString = #filePath, line: UInt = #line, _ condition: () -> Bool) {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() && Date() < deadline {
      RunLoop.current.run(until: Date().addingTimeInterval(0.01))
    }
    XCTAssertTrue(condition(), file: file, line: line)
  }
}

// MARK: - Domain (TDD: business logic)

final class FavoriteUseCaseTests: XCTestCase {
  private var repository: MockFavoriteRepository!

  override func setUp() {
    super.setUp()
    repository = MockFavoriteRepository()
  }

  override func tearDown() {
    repository = nil
    super.tearDown()
  }

  func testToggle_whenNotFavorite_addsAndReturnsTrue() throws {
    let sut = ToggleFavoriteInteractor(repository: repository)

    XCTAssertTrue(try value(of: sut.execute(request: Dummy.game(id: 7))))
    XCTAssertEqual(repository.addCount, 1)
    XCTAssertEqual(repository.stored.map(\.id), [7])
  }

  func testToggle_whenAlreadyFavorite_removesAndReturnsFalse() throws {
    repository.stored = [Dummy.game(id: 7)]
    let sut = ToggleFavoriteInteractor(repository: repository)

    XCTAssertFalse(try value(of: sut.execute(request: Dummy.game(id: 7))))
    XCTAssertEqual(repository.removeCount, 1)
    XCTAssertTrue(repository.stored.isEmpty)
  }

  func testToggle_withoutGame_failsWithInvalidRequest() {
    let sut = ToggleFavoriteInteractor(repository: repository)

    XCTAssertThrowsError(try value(of: sut.execute(request: nil))) { error in
      XCTAssertEqual(error as? CoreError, .invalidRequest)
    }
  }

  func testToggle_whenStorageFails_propagatesError() {
    repository.error = CoreError.database("penuh")
    let sut = ToggleFavoriteInteractor(repository: repository)

    XCTAssertThrowsError(try value(of: sut.execute(request: Dummy.game())))
  }

  func testCheckFavorite_reportsStatus() throws {
    repository.stored = [Dummy.game(id: 3)]
    let sut = CheckFavoriteInteractor(repository: repository)

    XCTAssertTrue(try value(of: sut.execute(request: 3)))
    XCTAssertFalse(try value(of: sut.execute(request: 4)))
  }

  func testRemove_withoutId_failsWithInvalidRequest() {
    let sut = RemoveFavoriteInteractor(repository: repository)

    XCTAssertThrowsError(try value(of: sut.execute(request: nil)))
  }

  func testGetFavorites_returnsStoredGames() throws {
    repository.stored = [Dummy.game(id: 1), Dummy.game(id: 2)]
    let sut = GetFavoritesInteractor(repository: repository)

    XCTAssertEqual(try value(of: sut.execute(request: nil)).map(\.id), [1, 2])
  }
}

// MARK: - Data (Core Data in-memory)

final class FavoriteRepositoryTests: XCTestCase {
  private var sut: FavoriteRepository<FavoriteLocalDataSource>!

  override func setUp() {
    super.setUp()
    sut = FavoriteRepository(local: FavoriteLocalDataSource(store: FavoriteStore(inMemory: true)))
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testAddCheckAndRemove() throws {
    let game = Dummy.game(id: 11)

    XCTAssertFalse(try value(of: sut.isFavorite(id: 11)))
    XCTAssertTrue(try value(of: sut.add(game)))
    XCTAssertTrue(try value(of: sut.isFavorite(id: 11)))
    XCTAssertEqual(try value(of: sut.getFavorites()), [game])
    XCTAssertTrue(try value(of: sut.remove(id: 11)))
    XCTAssertTrue(try value(of: sut.getFavorites()).isEmpty)
  }

  func testAddingSameGameTwiceKeepsOneRow() throws {
    _ = try value(of: sut.add(Dummy.game(id: 5)))
    _ = try value(of: sut.add(Dummy.game(id: 5, name: "Portal 2 GOTY")))

    let favorites = try value(of: sut.getFavorites())
    XCTAssertEqual(favorites.count, 1)
    XCTAssertEqual(favorites.first?.name, "Portal 2 GOTY")
  }
}

final class FavoriteMapperTests: XCTestCase {
  func testDomainToEntityAndBack_keepsValues() {
    let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    let game = FavoriteGame(id: 9, name: "Hades", imageURL: URL(string: "https://x.io/h.jpg"),
                            rating: 4.4, releaseDate: Date(timeIntervalSince1970: 0), genre: "Action")

    let entity = FavoriteDomainToEntityMapper(now: { fixedDate }).transform(game)
    let back = FavoriteEntityToDomainMapper().transform(entity)

    XCTAssertEqual(entity.released, "1970-01-01")
    XCTAssertEqual(entity.addedAt, fixedDate)
    XCTAssertEqual(back, game)
  }
}

// MARK: - Presentation

final class FavoritePresenterTests: XCTestCase {
  func testRemove_whenStorageFails_restoresItemsAndShowsAlert() {
    let games = [Dummy.game(id: 1), Dummy.game(id: 2)]
    let sut = FavoritePresenter(
      getFavorites: AnyUseCase { _ in Just(games).setFailureType(to: Error.self).eraseToAnyPublisher() },
      removeFavorite: AnyUseCase { _ in Fail(error: CoreError.database("x")).eraseToAnyPublisher() }
    )
    sut.load()
    waitUntil { sut.state == .loaded }

    sut.remove(games[0])

    XCTAssertEqual(sut.items.map(\.id), [2], "Dihapus secara optimis")
    waitUntil { sut.alertMessage != nil }
    XCTAssertEqual(sut.items.map(\.id), [1, 2], "Dikembalikan setelah gagal")
  }

  func testRemoveLastItem_stateBecomesEmpty() {
    let sut = FavoritePresenter(
      getFavorites: AnyUseCase { _ in Just([Dummy.game()]).setFailureType(to: Error.self).eraseToAnyPublisher() },
      removeFavorite: AnyUseCase { _ in Just(true).setFailureType(to: Error.self).eraseToAnyPublisher() }
    )
    sut.load()
    waitUntil { sut.state == .loaded }

    sut.remove(Dummy.game())

    XCTAssertEqual(sut.state, .empty)
  }
}
