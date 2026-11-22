//
//  GameTests.swift
//  GameTests
//

import Combine
@testable import Game
import GameVaultCore
import XCTest

// MARK: - Helpers

enum Dummy {
  static func game(id: Int) -> GameModel {
    GameModel(id: id, name: "Game \(id)", imageURL: nil, rating: 4, releaseDate: nil, genre: "Action")
  }

  static func page(_ ids: [Int], hasNext: Bool) -> GamePage {
    GamePage(games: ids.map { game(id: $0) }, hasNextPage: hasNext)
  }
}

/// Use case palsu yang mencatat setiap request yang diterima.
final class GamesUseCaseSpy {
  var results: [Result<GamePage, Error>] = []
  private(set) var requests: [GamesRequest] = []

  var useCase: AnyUseCase<GamesRequest, GamePage> {
    AnyUseCase { [unowned self] request in
      self.requests.append(request ?? GamesRequest())
      let result: Result<GamePage, Error> = self.results.isEmpty
        ? .success(Dummy.page([], hasNext: false))
        : self.results.removeFirst()
      return result.publisher.eraseToAnyPublisher()
    }
  }
}

extension XCTestCase {
  func waitUntil(timeout: TimeInterval = 1, file: StaticString = #filePath, line: UInt = #line, _ condition: () -> Bool) {
    let deadline = Date().addingTimeInterval(timeout)
    while !condition() && Date() < deadline {
      RunLoop.current.run(until: Date().addingTimeInterval(0.01))
    }
    XCTAssertTrue(condition(), file: file, line: line)
  }
}

// MARK: - Domain (TDD: aturan bisnis permintaan)

final class GamesRequestTests: XCTestCase {
  func testQueryIsTrimmedAndBlankBecomesNil() {
    XCTAssertEqual(GamesRequest(query: "  zelda ").query, "zelda")
    XCTAssertNil(GamesRequest(query: "   ").query)
    XCTAssertFalse(GamesRequest(query: "").isSearching)
  }

  func testPageAndPageSizeAreClamped() {
    XCTAssertEqual(GamesRequest(page: 0).page, 1)
    XCTAssertEqual(GamesRequest(pageSize: 0).pageSize, 1)
    XCTAssertEqual(GamesRequest(pageSize: 100).pageSize, GamesRequest.maxPageSize)
  }

  func testNextPageKeepsFilters() {
    let request = GamesRequest(page: 2, query: "mario", genreSlug: "action", ordering: .rating)

    let next = request.nextPage()

    XCTAssertEqual(next.page, 3)
    XCTAssertEqual(next.query, "mario")
    XCTAssertEqual(next.genreSlug, "action")
    XCTAssertEqual(next.ordering, .rating)
  }

  func testOrderingApiValues() {
    XCTAssertNil(GameOrdering.relevance.apiValue)
    XCTAssertEqual(GameOrdering.popular.apiValue, "-added")
    XCTAssertEqual(GameOrdering.rating.apiValue, "-rating")
    XCTAssertEqual(GameOrdering.newest.apiValue, "-released")
    XCTAssertEqual(GameOrdering.name.apiValue, "name")
  }

  func testAppendingUniqueSkipsDuplicates() {
    let merged = [Dummy.game(id: 1), Dummy.game(id: 2)].appendingUnique([Dummy.game(id: 2), Dummy.game(id: 3)])

    XCTAssertEqual(merged.map(\.id), [1, 2, 3])
  }
}

// MARK: - Data

final class GameDataTests: XCTestCase {
  func testParametersContainOnlyActiveFilters() {
    let plain = GamesRemoteDataSource.parameters(for: GamesRequest())
    XCTAssertNil(plain["search"])
    XCTAssertNil(plain["ordering"])
    XCTAssertEqual(plain["page"] as? Int, 1)

    let filtered = GamesRemoteDataSource.parameters(
      for: GamesRequest(query: "hades", genreSlug: "indie", ordering: .newest)
    )
    XCTAssertEqual(filtered["search"] as? String, "hades")
    XCTAssertEqual(filtered["genres"] as? String, "indie")
    XCTAssertEqual(filtered["ordering"] as? String, "-released")
  }

  func testGamesMapperHandlesNullFields() {
    let response = GameListResponse(
      next: nil,
      results: [GameResponse(id: 10, name: nil, backgroundImage: nil, rating: nil, released: nil, genres: nil)]
    )

    let page = GamesMapper().transform(response)

    XCTAssertFalse(page.hasNextPage)
    XCTAssertEqual(page.games.first?.id, 10)
    XCTAssertEqual(page.games.first?.rating, 0)
    XCTAssertNil(page.games.first?.imageURL)
  }

  func testGenresMapperDropsIncompleteItems() {
    let response = GenreListResponse(results: [
      GenreResponse(id: 1, name: "Action", slug: "action"),
      GenreResponse(id: 2, name: nil, slug: "x")
    ])

    XCTAssertEqual(GenresMapper().transform(response), [GenreModel(id: 1, name: "Action", slug: "action")])
  }
}

// MARK: - Presentation

final class HomePresenterTests: XCTestCase {
  private var spy: GamesUseCaseSpy!
  private var sut: HomePresenter!

  override func setUp() {
    super.setUp()
    spy = GamesUseCaseSpy()
    sut = HomePresenter(
      getGames: spy.useCase,
      getGenres: AnyUseCase { _ in Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() },
      searchDebounce: .milliseconds(10)
    )
  }

  override func tearDown() {
    sut = nil
    spy = nil
    super.tearDown()
  }

  func testOnAppear_loadsFirstPage() {
    spy.results = [.success(Dummy.page([1, 2], hasNext: true))]

    sut.onAppear()

    waitUntil { sut.state == .loaded }
    XCTAssertEqual(sut.games.map(\.id), [1, 2])
    XCTAssertEqual(spy.requests.first?.page, 1)
  }

  func testLoadMore_requestsNextPageAndAppends() {
    spy.results = [.success(Dummy.page([1, 2], hasNext: true)), .success(Dummy.page([3], hasNext: false))]
    sut.onAppear()
    waitUntil { sut.state == .loaded }

    sut.loadMoreIfNeeded(currentItem: Dummy.game(id: 2))

    waitUntil { sut.games.count == 3 }
    XCTAssertEqual(spy.requests.last?.page, 2)
  }

  func testLoadMore_ignoredWhenItemIsNotLast() {
    spy.results = [.success(Dummy.page([1, 2], hasNext: true))]
    sut.onAppear()
    waitUntil { sut.state == .loaded }

    sut.loadMoreIfNeeded(currentItem: Dummy.game(id: 1))

    XCTAssertEqual(spy.requests.count, 1)
  }

  func testFirstPageFailure_showsError() {
    spy.results = [.failure(CoreError.noConnection)]

    sut.onAppear()

    waitUntil {
      if case .error = sut.state { return true }
      return false
    }
  }

  func testSelectingOrdering_reloadsWithOrdering() {
    sut.onAppear()
    waitUntil { sut.state != .loading }

    sut.selectOrdering(.rating)

    waitUntil { spy.requests.count == 2 }
    XCTAssertEqual(spy.requests.last?.ordering, .rating)
    XCTAssertEqual(spy.requests.last?.page, 1)
  }

  func testSearchText_isDebouncedIntoRequest() {
    sut.onAppear()
    waitUntil { sut.state != .loading }

    sut.searchText = "  portal "

    waitUntil { spy.requests.last?.query == "portal" }
  }

  func testEmptyResult_stateIsEmpty() {
    spy.results = [.success(Dummy.page([], hasNext: false))]

    sut.onAppear()

    waitUntil { sut.state == .empty }
  }
}
