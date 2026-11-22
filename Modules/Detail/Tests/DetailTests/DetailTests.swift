//
//  DetailTests.swift
//  DetailTests
//

import Combine
@testable import Detail
import Favorite
import GameVaultCore
import XCTest

enum Dummy {
  static func detail(id: Int = 1, about: String = "Puzzle game.") -> GameDetailModel {
    GameDetailModel(
      id: id, name: "Portal 2", about: about, imageURL: nil, rating: 4.61, ratingsCount: 5000,
      releaseDate: nil, metacritic: 95, playtime: 11, website: nil,
      genres: ["Puzzle", "Shooter"], platforms: ["PC"], developers: ["Valve"]
    )
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

private func just<T>(_ value: T) -> AnyPublisher<T, Error> {
  Just(value).setFailureType(to: Error.self).eraseToAnyPublisher()
}

// MARK: - Domain (TDD)

final class DetailDomainTests: XCTestCase {
  func testMetascoreLevels() {
    XCTAssertEqual(MetascoreLevel(score: 92), .favorable)
    XCTAssertEqual(MetascoreLevel(score: 75), .favorable)
    XCTAssertEqual(MetascoreLevel(score: 74), .mixed)
    XCTAssertEqual(MetascoreLevel(score: 50), .mixed)
    XCTAssertEqual(MetascoreLevel(score: 49), .unfavorable)
  }

  func testLongDescriptionThreshold() {
    XCTAssertFalse(Dummy.detail(about: String(repeating: "a", count: 220)).hasLongDescription)
    XCTAssertTrue(Dummy.detail(about: String(repeating: "a", count: 221)).hasLongDescription)
  }

  func testFavoriteGameUsesFirstGenre() {
    let favorite = Dummy.detail(id: 3).favoriteGame

    XCTAssertEqual(favorite.id, 3)
    XCTAssertEqual(favorite.genre, "Puzzle")
    XCTAssertEqual(favorite.name, "Portal 2")
  }
}

// MARK: - Data

final class DetailMapperTests: XCTestCase {
  private func response(raw: String?, html: String?) -> GameDetailResponse {
    GameDetailResponse(
      id: 1, name: "Portal 2", descriptionRaw: raw, description: html, backgroundImage: nil,
      rating: nil, ratingsCount: nil, released: "2011-04-18", metacritic: nil, playtime: nil,
      website: "", genres: [NamedResponse(id: 1, name: "Puzzle")],
      platforms: [PlatformWrapperResponse(platform: NamedResponse(id: 4, name: "PC")), PlatformWrapperResponse(platform: nil)],
      developers: nil
    )
  }

  func testUsesRawDescriptionWhenAvailable() {
    let model = GameDetailMapper().transform(response(raw: "  Plain text  ", html: "<p>HTML</p>"))

    XCTAssertEqual(model.about, "Plain text")
    XCTAssertEqual(model.platforms, ["PC"])
    XCTAssertNil(model.website, "Website kosong dianggap tidak ada")
    XCTAssertNotNil(model.releaseDate)
  }

  func testFallsBackToStrippedHTML() {
    let model = GameDetailMapper().transform(response(raw: nil, html: "<p>Hello &amp; welcome</p>"))

    XCTAssertEqual(model.about, "Hello & welcome")
  }

  func testScreenshotsMapperDropsInvalidURLs() {
    let list = ScreenshotListResponse(results: [
      ScreenshotResponse(id: 1, image: "https://media.rawg.io/media/screenshots/a.jpg"),
      ScreenshotResponse(id: 2, image: nil)
    ])

    XCTAssertEqual(ScreenshotsMapper().transform(list).map(\.id), [1])
  }
}

// MARK: - Presentation

final class DetailPresenterTests: XCTestCase {
  private func makePresenter(
    detail: AnyPublisher<GameDetailModel, Error> = just(Dummy.detail()),
    screenshots: AnyPublisher<[ScreenshotModel], Error> = just([]),
    isFavorite: Bool = false,
    toggleResult: AnyPublisher<Bool, Error> = just(true)
  ) -> DetailPresenter {
    DetailPresenter(
      gameId: 1,
      getDetail: AnyUseCase { _ in detail },
      getScreenshots: AnyUseCase { _ in screenshots },
      checkFavorite: AnyUseCase { _ in just(isFavorite) },
      toggleFavorite: AnyUseCase { _ in toggleResult }
    )
  }

  func testOnAppear_loadsDetailScreenshotsAndFavoriteStatus() throws {
    let shot = ScreenshotModel(id: 9, imageURL: try XCTUnwrap(URL(string: "https://x.io/s.jpg")))
    let sut = makePresenter(screenshots: just([shot]), isFavorite: true)

    sut.onAppear()

    waitUntil { sut.state == .loaded && sut.isFavorite && !sut.screenshots.isEmpty }
    XCTAssertEqual(sut.item?.id, 1)
  }

  func testScreenshotFailure_doesNotBreakDetail() {
    let sut = makePresenter(screenshots: Fail(error: CoreError.server(statusCode: 500)).eraseToAnyPublisher())

    sut.onAppear()

    waitUntil { sut.state == .loaded }
    XCTAssertTrue(sut.screenshots.isEmpty)
  }

  func testToggleFavorite_updatesStatusAndShowsToast() {
    let sut = makePresenter(toggleResult: just(true))
    sut.onAppear()
    waitUntil { sut.state == .loaded }

    sut.toggleFavoriteStatus()

    waitUntil { sut.isFavorite && sut.toastMessage != nil }
    XCTAssertFalse(sut.isUpdatingFavorite)
  }

  func testToggleFavorite_failureShowsAlert() {
    let sut = makePresenter(toggleResult: Fail(error: CoreError.database("x")).eraseToAnyPublisher())
    sut.onAppear()
    waitUntil { sut.state == .loaded }

    sut.toggleFavoriteStatus()

    waitUntil { sut.alertMessage != nil }
    XCTAssertFalse(sut.isFavorite)
  }

  func testDetailFailure_showsErrorState() {
    let sut = makePresenter(detail: Fail(error: CoreError.notFound).eraseToAnyPublisher())

    sut.onAppear()

    waitUntil {
      if case .error = sut.state { return true }
      return false
    }
  }
}
