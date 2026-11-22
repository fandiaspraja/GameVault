//
//  CommonTests.swift
//  CommonTests
//

import Alamofire
import Combine
@testable import Common
import GameVaultCore
import XCTest

final class LocalizationTests: XCTestCase {
  private func keys(for language: String) throws -> Set<String> {
    let path = try XCTUnwrap(
      L10n.bundle.path(forResource: "Localizable", ofType: "strings", inDirectory: nil, forLocalization: language),
      "Localizable.strings untuk \(language) tidak ditemukan"
    )
    let dictionary = try XCTUnwrap(NSDictionary(contentsOfFile: path) as? [String: String])
    return Set(dictionary.keys)
  }

  func testIndonesianAndEnglishHaveSameKeys() throws {
    let indonesian = try keys(for: "id")
    let english = try keys(for: "en")

    XCTAssertFalse(indonesian.isEmpty)
    XCTAssertEqual(indonesian.subtracting(english), [], "Kunci yang belum diterjemahkan ke Inggris")
    XCTAssertEqual(english.subtracting(indonesian), [], "Kunci yang belum diterjemahkan ke Indonesia")
  }

  func testEveryKeyResolvesToTranslation() {
    XCTAssertNotEqual(L10n.Tab.home, "tab.home")
    XCTAssertNotEqual(L10n.Detail.screenshots, "detail.screenshots")
  }
}

final class ErrorMessageTests: XCTestCase {
  func testCoreErrorsMapToLocalizedMessages() {
    XCTAssertEqual(ErrorMessage.from(CoreError.noConnection), L10n.Errors.noConnection)
    XCTAssertEqual(ErrorMessage.from(CoreError.unauthorized), L10n.Errors.unauthorized)
    XCTAssertEqual(ErrorMessage.from(CoreError.server(statusCode: 500)), L10n.Errors.server)
  }

  func testUnknownErrorUsesFallbackMessage() {
    struct SomeError: Error {}
    XCTAssertEqual(ErrorMessage.from(SomeError()), L10n.Errors.unknown)
  }
}

final class NetworkErrorMapperTests: XCTestCase {
  func testOfflineErrorMapsToNoConnection() {
    let error = AFError.sessionTaskFailed(error: URLError(.notConnectedToInternet))
    XCTAssertEqual(NetworkErrorMapper.map(error), .noConnection)
  }

  func testUnauthorizedStatusMapsToUnauthorized() {
    let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 401))
    XCTAssertEqual(NetworkErrorMapper.map(error), .unauthorized)
  }

  func testNotFoundStatusMapsToNotFound() {
    let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
    XCTAssertEqual(NetworkErrorMapper.map(error), .notFound)
  }

  func testServerStatusKeepsCode() {
    let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 503))
    XCTAssertEqual(NetworkErrorMapper.map(error), .server(statusCode: 503))
  }

  func testEmptyAPIKeyFailsFastWithUnauthorized() {
    let client = RAWGClient(configuration: APIConfiguration(apiKey: ""))
    let expectation = self.expectation(description: "gagal")
    let publisher: AnyPublisher<EmptyDecodable, Error> = client.get("games")
    let cancellable = publisher.sink { completion in
      if case .failure(let error) = completion {
        XCTAssertEqual(error as? CoreError, .unauthorized)
        expectation.fulfill()
      }
    } receiveValue: { _ in }
    wait(for: [expectation], timeout: 1)
    cancellable.cancel()
  }
}

struct EmptyDecodable: Decodable {}

final class FormattingTests: XCTestCase {
  func testRawgResized_insertsCropPath() throws {
    let url = try XCTUnwrap(URL(string: "https://media.rawg.io/media/games/abc.jpg"))
    XCTAssertEqual(url.rawgResized().absoluteString, "https://media.rawg.io/media/crop/600/400/games/abc.jpg")
  }

  func testRawgResized_ignoresOtherHosts() throws {
    let url = try XCTUnwrap(URL(string: "https://example.com/media/a.jpg"))
    XCTAssertEqual(url.rawgResized(), url)
  }

  func testAPIDate_roundTrip() {
    let date = APIDate.parse("2013-09-17")
    XCTAssertNotNil(date)
    XCTAssertEqual(APIDate.string(from: date), "2013-09-17")
    XCTAssertNil(APIDate.parse(""))
  }

  func testDateFormatter_returnsTBAForNil() {
    XCTAssertEqual(AppFormatter.date(nil), L10n.General.tba)
  }
}
