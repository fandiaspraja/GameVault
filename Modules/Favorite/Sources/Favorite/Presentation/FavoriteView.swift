//
//  FavoriteView.swift
//  Favorite
//

import Common
import GameVaultCore
import SwiftUI

/// Halaman Favorit. Tujuan navigasi detail disuntikkan dari luar (Router di aplikasi),
/// sehingga modul ini tidak bergantung pada modul Detail.
public struct FavoriteView<Destination: View>: View {
  @StateObject private var presenter: FavoritePresenter
  private let destination: (Int) -> Destination

  public init(presenter: FavoritePresenter, @ViewBuilder destination: @escaping (Int) -> Destination) {
    _presenter = StateObject(wrappedValue: presenter)
    self.destination = destination
  }

  public var body: some View {
    content
      .navigationTitle(L10n.Favorite.title)
      .navigationDestination(for: GameRoute.self) { route in
        destination(route.id)
      }
      .alert(
        L10n.General.errorTitle,
        isPresented: Binding(
          get: { presenter.alertMessage != nil },
          set: { if !$0 { presenter.dismissAlert() } }
        )
      ) {
        Button(L10n.General.ok, role: .cancel) {}
      } message: {
        Text(presenter.alertMessage ?? "")
      }
      .onAppear { presenter.load() }
  }

  @ViewBuilder
  private var content: some View {
    switch presenter.state {
    case .idle, .loading:
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    case .error(let message):
      ErrorStateView(message: message) { presenter.load() }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    case .empty:
      EmptyStateView(
        systemImage: "heart.slash",
        title: L10n.Favorite.emptyTitle,
        message: L10n.Favorite.emptyMessage
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity)

    case .loaded:
      List {
        Section {
          ForEach(presenter.items) { game in
            NavigationLink(value: GameRoute(id: game.id)) {
              GameRowView(
                title: game.name,
                imageURL: game.imageURL,
                releaseDate: game.releaseDate,
                genre: game.genre,
                rating: game.rating
              )
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button(role: .destructive) {
                presenter.remove(game)
              } label: {
                Label(L10n.Favorite.delete, systemImage: "trash")
              }
            }
          }
        } header: {
          Text(L10n.Favorite.count(presenter.items.count))
            .textCase(nil)
        }
      }
      .listStyle(.plain)
    }
  }
}
