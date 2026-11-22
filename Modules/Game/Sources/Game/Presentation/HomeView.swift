//
//  HomeView.swift
//  Game
//

import Common
import GameVaultCore
import SwiftUI

/// Halaman Beranda. Tujuan navigasi detail disuntikkan dari Router aplikasi.
public struct HomeView<Destination: View>: View {
  @StateObject private var presenter: HomePresenter
  private let destination: (Int) -> Destination

  public init(presenter: HomePresenter, @ViewBuilder destination: @escaping (Int) -> Destination) {
    _presenter = StateObject(wrappedValue: presenter)
    self.destination = destination
  }

  public var body: some View {
    List {
      genreFilter
      content
    }
    .listStyle(.plain)
    .navigationTitle(L10n.Home.title)
    .searchable(
      text: $presenter.searchText,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: L10n.Home.searchPrompt
    )
    .autocorrectionDisabled()
    .refreshable { presenter.reload() }
    .toolbar {
      ToolbarItem(placement: .primaryAction) { sortMenu }
    }
    .navigationDestination(for: GameRoute.self) { route in
      destination(route.id)
    }
    .onAppear { presenter.onAppear() }
  }

  // MARK: - Sections

  private var sortMenu: some View {
    Menu {
      Picker(
        L10n.Home.sort,
        selection: Binding(get: { presenter.ordering }, set: { presenter.selectOrdering($0) })
      ) {
        ForEach(GameOrdering.allCases) { ordering in
          Text(ordering.title).tag(ordering)
        }
      }
    } label: {
      Label(L10n.Home.sort, systemImage: "arrow.up.arrow.down")
    }
    .accessibilityLabel("\(L10n.Home.sort): \(presenter.ordering.title)")
  }

  private var genreFilter: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        SelectableChip(title: L10n.Home.allGenres, isSelected: presenter.selectedGenre == nil) {
          presenter.selectGenre(nil)
        }
        ForEach(presenter.genres) { genre in
          SelectableChip(title: genre.name, isSelected: presenter.selectedGenre == genre) {
            presenter.selectGenre(genre)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 4)
    }
    .listRowInsets(EdgeInsets())
    .listRowSeparator(.hidden)
  }

  @ViewBuilder
  private var content: some View {
    switch presenter.state {
    case .idle, .loading:
      ForEach(0..<6, id: \.self) { _ in
        SkeletonRowView()
      }
      .listRowSeparator(.hidden)

    case .error(let message):
      ErrorStateView(message: message) { presenter.reload() }
        .padding(.vertical, 80)
        .listRowSeparator(.hidden)

    case .empty:
      emptyView
        .padding(.vertical, 80)
        .listRowSeparator(.hidden)

    case .loaded:
      ForEach(presenter.games) { game in
        NavigationLink(value: GameRoute(id: game.id)) {
          GameRowView(
            title: game.name,
            imageURL: game.imageURL,
            releaseDate: game.releaseDate,
            genre: game.genre,
            rating: game.rating
          )
        }
        .onAppear { presenter.loadMoreIfNeeded(currentItem: game) }
      }

      if presenter.isLoadingMore {
        ProgressView()
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .listRowSeparator(.hidden)
      }
    }
  }

  @ViewBuilder
  private var emptyView: some View {
    if presenter.isSearching {
      EmptyStateView(
        systemImage: "magnifyingglass",
        title: L10n.Home.noResultTitle,
        message: L10n.Home.noResultMessage(presenter.searchText)
      )
    } else {
      EmptyStateView(
        systemImage: "gamecontroller",
        title: L10n.Home.emptyTitle,
        message: L10n.Home.emptyMessage
      )
    }
  }
}
