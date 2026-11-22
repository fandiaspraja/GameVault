//
//  RAWGClient.swift
//  Common
//

import Alamofire
import Combine
import Foundation
import GameVaultCore

public struct APIConfiguration: Equatable {
  public let baseURL: String
  public let apiKey: String

  public init(baseURL: String = "https://api.rawg.io/api", apiKey: String) {
    self.baseURL = baseURL
    self.apiKey = apiKey
  }
}

/// Klien HTTP bersama (Alamofire + Combine) untuk seluruh modul fitur.
public final class RAWGClient {
  private let configuration: APIConfiguration
  private let session: Session
  private let decoder: JSONDecoder

  public init(configuration: APIConfiguration, session: Session = .default) {
    self.configuration = configuration
    self.session = session
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    self.decoder = decoder
  }

  public func get<T: Decodable>(_ path: String, parameters: [String: Any] = [:]) -> AnyPublisher<T, Error> {
    guard !configuration.apiKey.isEmpty else {
      return Fail(error: CoreError.unauthorized).eraseToAnyPublisher()
    }
    var allParameters = parameters
    allParameters["key"] = configuration.apiKey

    return session.request("\(configuration.baseURL)/\(path)", parameters: allParameters)
      .validate()
      .publishDecodable(type: T.self, decoder: decoder)
      .value()
      .mapError { NetworkErrorMapper.map($0) }
      .eraseToAnyPublisher()
  }
}

/// Menerjemahkan error Alamofire menjadi `CoreError`.
public enum NetworkErrorMapper {
  public static func map(_ error: AFError) -> CoreError {
    if let urlError = error.underlyingError as? URLError,
       [.notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost].contains(urlError.code) {
      return .noConnection
    }
    if error.isResponseSerializationError {
      return .decoding
    }
    switch error.responseCode {
    case 401, 403: return .unauthorized
    case 404: return .notFound
    default: return .server(statusCode: error.responseCode)
    }
  }
}
