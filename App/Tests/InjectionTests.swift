//
//  InjectionTests.swift
//  GameVaultTests
//
//  Memastikan seluruh dependensi antarmodul terdaftar dan bisa dirangkai.
//

import Detail
import Favorite
import Game
@testable import GameVault
import GameVaultCore
import XCTest

final class InjectionTests: XCTestCase {
  private var sut: Injection!

  override func setUp() {
    super.setUp()
    sut = Injection(apiKey: "test-key", inMemoryStore: true)
  }

  override func tearDown() {
    sut = nil
    super.tearDown()
  }

  func testAllPresentersResolve() {
    XCTAssertNotNil(sut.resolver.resolve(HomePresenter.self))
    XCTAssertNotNil(sut.resolver.resolve(FavoritePresenter.self))
    XCTAssertEqual(sut.resolver.resolve(DetailPresenter.self, argument: 42)?.gameId, 42)
  }

  func testNamedFavoriteUseCasesAreDistinct() {
    XCTAssertNotNil(sut.resolver.resolve(AnyUseCase<Int, Bool>.self, name: ServiceName.checkFavorite))
    XCTAssertNotNil(sut.resolver.resolve(AnyUseCase<Int, Bool>.self, name: ServiceName.removeFavorite))
    XCTAssertNotNil(sut.resolver.resolve(AnyUseCase<FavoriteGame, Bool>.self))
  }

  func testFavoriteStoreIsSharedSingleton() {
    let first = sut.resolver.resolve(FavoriteStore.self)
    let second = sut.resolver.resolve(FavoriteStore.self)

    XCTAssertNotNil(first)
    XCTAssertTrue(first === second)
  }

  func testRouterBuildsEveryScreen() {
    let router = Router(resolver: sut.resolver)

    _ = router.makeHomeView()
    _ = router.makeFavoriteView()
    _ = router.makeDetailView(gameId: 1)
    _ = router.makeAboutView()
  }
}
