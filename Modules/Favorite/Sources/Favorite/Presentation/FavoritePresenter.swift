//
//  FavoritePresenter.swift
//  Favorite
//

import Combine
import Common
import Foundation
import GameVaultCore

/// Turunan `ListPresenter` generik dari GameVaultCore, ditambah aksi hapus.
public final class FavoritePresenter: ListPresenter<Void, FavoriteGame> {
  @Published public private(set) var alertMessage: String?

  private let removeFavorite: AnyUseCase<Int, Bool>
  private var cancellables = Set<AnyCancellable>()

  public init(getFavorites: AnyUseCase<Void, [FavoriteGame]>, removeFavorite: AnyUseCase<Int, Bool>) {
    self.removeFavorite = removeFavorite
    super.init(useCase: getFavorites, errorMessage: ErrorMessage.from)
  }

  /// Hapus secara optimis; kembalikan daftar bila penyimpanan gagal.
  public func remove(_ game: FavoriteGame) {
    let snapshot = items
    replaceItems(items.filter { $0.id != game.id })

    removeFavorite.execute(request: game.id)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard let self, case .failure(let error) = completion else { return }
        self.replaceItems(snapshot)
        self.alertMessage = ErrorMessage.from(error)
      } receiveValue: { _ in }
      .store(in: &cancellables)
  }

  public func dismissAlert() {
    alertMessage = nil
  }
}
