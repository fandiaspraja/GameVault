//
//  GameMappers.swift
//  Game
//

import Common
import Foundation
import GameVaultCore

/// Response -> Domain untuk daftar gim.
public struct GamesMapper: Mapper {
  public init() {}

  public func transform(_ input: GameListResponse) -> GamePage {
    GamePage(games: input.results.map(Self.map), hasNextPage: input.next != nil)
  }

  static func map(_ response: GameResponse) -> GameModel {
    GameModel(
      id: response.id,
      name: response.name ?? L10n.General.untitled,
      imageURL: response.backgroundImage.flatMap(URL.init(string:)),
      rating: response.rating ?? 0,
      releaseDate: APIDate.parse(response.released),
      genre: response.genres?.first?.name
    )
  }
}

/// Response -> Domain untuk genre (item tanpa nama/slug dibuang).
public struct GenresMapper: Mapper {
  public init() {}

  public func transform(_ input: GenreListResponse) -> [GenreModel] {
    input.results.compactMap { response in
      guard let name = response.name, let slug = response.slug else { return nil }
      return GenreModel(id: response.id, name: name, slug: slug)
    }
  }
}
