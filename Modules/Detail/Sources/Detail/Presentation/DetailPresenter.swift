//
//  DetailPresenter.swift
//  Detail
//

import Combine
import Common
import Favorite
import Foundation
import GameVaultCore

/// Turunan `ItemPresenter` generik dari GameVaultCore, ditambah screenshot & favorit.
public final class DetailPresenter: ItemPresenter<Int, GameDetailModel> {
  @Published public private(set) var screenshots: [ScreenshotModel] = []
  @Published public private(set) var isFavorite = false
  @Published public private(set) var isUpdatingFavorite = false
  @Published public private(set) var toastMessage: String?
  @Published public private(set) var alertMessage: String?

  public let gameId: Int
  private let getScreenshots: AnyUseCase<Int, [ScreenshotModel]>
  private let checkFavorite: AnyUseCase<Int, Bool>
  private let toggleFavorite: AnyUseCase<FavoriteGame, Bool>
  private var cancellables = Set<AnyCancellable>()
  private var toastWorkItem: DispatchWorkItem?

  public init(
    gameId: Int,
    getDetail: AnyUseCase<Int, GameDetailModel>,
    getScreenshots: AnyUseCase<Int, [ScreenshotModel]>,
    checkFavorite: AnyUseCase<Int, Bool>,
    toggleFavorite: AnyUseCase<FavoriteGame, Bool>
  ) {
    self.gameId = gameId
    self.getScreenshots = getScreenshots
    self.checkFavorite = checkFavorite
    self.toggleFavorite = toggleFavorite
    super.init(useCase: getDetail, errorMessage: ErrorMessage.from)
  }

  // MARK: - Intent

  public func onAppear() {
    if state == .idle {
      retry()
    }
    refreshFavoriteStatus()
  }

  public func retry() {
    load(request: gameId)
    loadScreenshots()
  }

  public func toggleFavoriteStatus() {
    guard let item, !isUpdatingFavorite else { return }
    isUpdatingFavorite = true

    toggleFavorite.execute(request: item.favoriteGame)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard let self else { return }
        self.isUpdatingFavorite = false
        if case .failure(let error) = completion {
          self.alertMessage = ErrorMessage.from(error)
        }
      } receiveValue: { [weak self] isFavorite in
        self?.isFavorite = isFavorite
        self?.showToast(isFavorite ? L10n.Detail.addedToast : L10n.Detail.removedToast)
      }
      .store(in: &cancellables)
  }

  public func dismissAlert() {
    alertMessage = nil
  }

  // MARK: - Private

  /// Screenshot bersifat pelengkap: bila gagal, bagian galeri cukup disembunyikan.
  private func loadScreenshots() {
    getScreenshots.execute(request: gameId)
      .replaceError(with: [])
      .receive(on: DispatchQueue.main)
      .sink { [weak self] screenshots in self?.screenshots = screenshots }
      .store(in: &cancellables)
  }

  private func refreshFavoriteStatus() {
    checkFavorite.execute(request: gameId)
      .replaceError(with: false)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isFavorite in self?.isFavorite = isFavorite }
      .store(in: &cancellables)
  }

  private func showToast(_ message: String) {
    toastWorkItem?.cancel()
    toastMessage = message
    let workItem = DispatchWorkItem { [weak self] in self?.toastMessage = nil }
    toastWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: workItem)
  }
}

public extension GameDetailModel {
  /// Ringkasan detail dalam bentuk model domain modul Favorite.
  var favoriteGame: FavoriteGame {
    FavoriteGame(
      id: id,
      name: name,
      imageURL: imageURL,
      rating: rating,
      releaseDate: releaseDate,
      genre: genres.first
    )
  }
}
