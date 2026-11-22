//
//  Router.swift
//  GameVault
//
//  Membuat setiap halaman (dari modul fitur) beserta presenternya melalui container DI,
//  sekaligus menghubungkan navigasi antarmodul tanpa membuat modul saling bergantung.
//

import About
import Detail
import Favorite
import Game
import SwiftUI
import Swinject

final class Router {
  private let resolver: Resolver

  init(resolver: Resolver) {
    self.resolver = resolver
  }

  func makeHomeView() -> HomeView<DetailView> {
    HomeView(presenter: resolver.resolveOrFail(HomePresenter.self)) { [unowned self] gameId in
      self.makeDetailView(gameId: gameId)
    }
  }

  func makeFavoriteView() -> FavoriteView<DetailView> {
    FavoriteView(presenter: resolver.resolveOrFail(FavoritePresenter.self)) { [unowned self] gameId in
      self.makeDetailView(gameId: gameId)
    }
  }

  func makeDetailView(gameId: Int) -> DetailView {
    DetailView(presenter: resolver.resolveOrFail(DetailPresenter.self, argument: gameId))
  }

  func makeAboutView() -> AboutView {
    AboutView(profile: .owner, appVersion: AppConfiguration.appVersion)
  }
}
