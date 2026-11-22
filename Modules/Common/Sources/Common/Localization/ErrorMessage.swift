//
//  ErrorMessage.swift
//  Common
//

import Foundation
import GameVaultCore

/// Menerjemahkan error apa pun menjadi pesan yang ramah pengguna & terlokalisasi.
public enum ErrorMessage {
  public static func from(_ error: Error) -> String {
    guard let coreError = error as? CoreError else {
      return L10n.Errors.unknown
    }
    switch coreError {
    case .noConnection: return L10n.Errors.noConnection
    case .unauthorized: return L10n.Errors.unauthorized
    case .server: return L10n.Errors.server
    case .decoding: return L10n.Errors.decoding
    case .database: return L10n.Errors.database
    case .notFound: return L10n.Errors.notFound
    case .invalidRequest: return L10n.Errors.invalidRequest
    }
  }
}
