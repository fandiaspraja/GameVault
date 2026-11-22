//
//  HomePresenter.swift
//  Game
//

import Combine
import Common
import Foundation
import GameVaultCore

public final class HomePresenter: ObservableObject {
  @Published public private(set) var games: [GameModel] = []
  @Published public private(set) var genres: [GenreModel] = []
  @Published public private(set) var selectedGenre: GenreModel?
  @Published public private(set) var ordering: GameOrdering = .relevance
  @Published public private(set) var state: ViewState = .idle
  @Published public private(set) var isLoadingMore = false
  @Published public var searchText = ""

  private let getGames: AnyUseCase<GamesRequest, GamePage>
  private let getGenres: AnyUseCase<Void, [GenreModel]>
  private var currentRequest = GamesRequest()
  private var hasNextPage = true
  private var gamesCancellable: AnyCancellable?
  private var cancellables = Set<AnyCancellable>()

  public init(
    getGames: AnyUseCase<GamesRequest, GamePage>,
    getGenres: AnyUseCase<Void, [GenreModel]>,
    searchDebounce: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
  ) {
    self.getGames = getGames
    self.getGenres = getGenres
    bindSearch(debounce: searchDebounce)
  }

  public var isSearching: Bool {
    currentRequest.isSearching
  }

  // MARK: - Intent

  public func onAppear() {
    guard state == .idle else { return }
    loadGenres()
    reload()
  }

  public func reload() {
    currentRequest = GamesRequest(
      query: searchText,
      genreSlug: selectedGenre?.slug,
      ordering: ordering
    )
    hasNextPage = true
    isLoadingMore = false
    games = []
    state = .loading
    fetch(currentRequest)
  }

  public func selectGenre(_ genre: GenreModel?) {
    guard genre != selectedGenre else { return }
    selectedGenre = genre
    reload()
  }

  public func selectOrdering(_ newOrdering: GameOrdering) {
    guard newOrdering != ordering else { return }
    ordering = newOrdering
    reload()
  }

  /// Infinite scroll: memuat halaman berikutnya saat item terakhir tampil.
  public func loadMoreIfNeeded(currentItem game: GameModel) {
    guard game.id == games.last?.id, hasNextPage, !isLoadingMore, state == .loaded else { return }
    isLoadingMore = true
    fetch(currentRequest.nextPage())
  }

  // MARK: - Private

  /// Pencarian reaktif: menunggu pengguna berhenti mengetik, abaikan input yang sama.
  private func bindSearch(debounce: DispatchQueue.SchedulerTimeType.Stride) {
    $searchText
      .dropFirst()
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .removeDuplicates()
      .debounce(for: debounce, scheduler: DispatchQueue.main)
      .sink { [weak self] _ in self?.reload() }
      .store(in: &cancellables)
  }

  private func fetch(_ request: GamesRequest) {
    gamesCancellable = getGames.execute(request: request)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard let self else { return }
        self.isLoadingMore = false
        if case .failure(let error) = completion, request.page == 1 {
          self.state = .error(ErrorMessage.from(error))
        }
      } receiveValue: { [weak self] page in
        guard let self else { return }
        self.currentRequest = request
        self.games = self.games.appendingUnique(page.games)
        self.hasNextPage = page.hasNextPage
        self.state = self.games.isEmpty ? .empty : .loaded
      }
  }

  private func loadGenres() {
    getGenres.execute(request: nil)
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .sink { [weak self] genres in self?.genres = genres }
      .store(in: &cancellables)
  }
}

public extension GameOrdering {
  var title: String {
    switch self {
    case .relevance: return L10n.Home.sortRelevance
    case .popular: return L10n.Home.sortPopular
    case .rating: return L10n.Home.sortRating
    case .newest: return L10n.Home.sortNewest
    case .name: return L10n.Home.sortName
    }
  }
}
