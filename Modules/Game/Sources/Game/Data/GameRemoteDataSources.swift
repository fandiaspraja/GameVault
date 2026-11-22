//
//  GameRemoteDataSources.swift
//  Game
//

import Combine
import Common
import Foundation
import GameVaultCore

/// Daftar gim (dengan pencarian, filter genre, urutan, dan pagination).
public final class GamesRemoteDataSource: DataSource {
  public typealias Request = GamesRequest
  public typealias Response = GameListResponse

  private let client: RAWGClient

  public init(client: RAWGClient) {
    self.client = client
  }

  public func execute(request: GamesRequest?) -> AnyPublisher<GameListResponse, Error> {
    client.get("games", parameters: Self.parameters(for: request ?? GamesRequest()))
  }

  static func parameters(for request: GamesRequest) -> [String: Any] {
    var parameters: [String: Any] = ["page": request.page, "page_size": request.pageSize]
    if let query = request.query {
      parameters["search"] = query
      parameters["search_precise"] = "true"
    }
    if let genre = request.genreSlug {
      parameters["genres"] = genre
    }
    if let ordering = request.ordering.apiValue {
      parameters["ordering"] = ordering
    }
    return parameters
  }
}

/// Daftar genre untuk chip filter.
public final class GenresRemoteDataSource: DataSource {
  public typealias Request = Void
  public typealias Response = GenreListResponse

  private let client: RAWGClient

  public init(client: RAWGClient) {
    self.client = client
  }

  public func execute(request: Void?) -> AnyPublisher<GenreListResponse, Error> {
    client.get("genres", parameters: ["ordering": "-games_count", "page_size": 20])
  }
}
