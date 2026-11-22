//
//  DetailData.swift
//  Detail
//
//  Response, DataSource, dan Mapper untuk halaman detail.
//

import Combine
import Common
import Foundation
import GameVaultCore

// MARK: - Response

public struct GameDetailResponse: Decodable {
  public let id: Int
  public let name: String?
  public let descriptionRaw: String?
  public let description: String?
  public let backgroundImage: String?
  public let rating: Double?
  public let ratingsCount: Int?
  public let released: String?
  public let metacritic: Int?
  public let playtime: Int?
  public let website: String?
  public let genres: [NamedResponse]?
  public let platforms: [PlatformWrapperResponse]?
  public let developers: [NamedResponse]?
}

public struct NamedResponse: Decodable {
  public let id: Int
  public let name: String?
}

public struct PlatformWrapperResponse: Decodable {
  public let platform: NamedResponse?
}

public struct ScreenshotListResponse: Decodable {
  public let results: [ScreenshotResponse]
}

public struct ScreenshotResponse: Decodable {
  public let id: Int
  public let image: String?
}

// MARK: - Remote Data Source

public final class GameDetailRemoteDataSource: DataSource {
  public typealias Request = Int
  public typealias Response = GameDetailResponse

  private let client: RAWGClient

  public init(client: RAWGClient) {
    self.client = client
  }

  public func execute(request id: Int?) -> AnyPublisher<GameDetailResponse, Error> {
    guard let id else { return Fail(error: CoreError.invalidRequest).eraseToAnyPublisher() }
    return client.get("games/\(id)")
  }
}

public final class ScreenshotsRemoteDataSource: DataSource {
  public typealias Request = Int
  public typealias Response = ScreenshotListResponse

  private let client: RAWGClient

  public init(client: RAWGClient) {
    self.client = client
  }

  public func execute(request id: Int?) -> AnyPublisher<ScreenshotListResponse, Error> {
    guard let id else { return Fail(error: CoreError.invalidRequest).eraseToAnyPublisher() }
    return client.get("games/\(id)/screenshots", parameters: ["page_size": 10])
  }
}

// MARK: - Mapper

public struct GameDetailMapper: Mapper {
  public init() {}

  public func transform(_ input: GameDetailResponse) -> GameDetailModel {
    let raw = input.descriptionRaw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return GameDetailModel(
      id: input.id,
      name: input.name ?? L10n.General.untitled,
      about: raw.isEmpty ? Self.stripHTML(input.description ?? "") : raw,
      imageURL: input.backgroundImage.flatMap(URL.init(string:)),
      rating: input.rating ?? 0,
      ratingsCount: input.ratingsCount ?? 0,
      releaseDate: APIDate.parse(input.released),
      metacritic: input.metacritic,
      playtime: input.playtime ?? 0,
      website: input.website.flatMap { $0.isEmpty ? nil : URL(string: $0) },
      genres: input.genres?.compactMap(\.name) ?? [],
      platforms: input.platforms?.compactMap { $0.platform?.name } ?? [],
      developers: input.developers?.compactMap(\.name) ?? []
    )
  }

  /// Menghapus tag HTML dan entitas umum dari teks.
  static func stripHTML(_ html: String) -> String {
    var text = html.replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
    text = text.replacingOccurrences(of: "</p>", with: "\n\n")
    text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    let entities = ["&amp;": "&", "&quot;": "\"", "&#39;": "'", "&lt;": "<", "&gt;": ">", "&nbsp;": " "]
    for (entity, character) in entities {
      text = text.replacingOccurrences(of: entity, with: character)
    }
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

public struct ScreenshotsMapper: Mapper {
  public init() {}

  public func transform(_ input: ScreenshotListResponse) -> [ScreenshotModel] {
    input.results.compactMap { response in
      guard let url = response.image.flatMap(URL.init(string:)) else { return nil }
      return ScreenshotModel(id: response.id, imageURL: url)
    }
  }
}
