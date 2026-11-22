//
//  ProfileTests.swift
//  AboutTests
//

@testable import About
import XCTest

final class ProfileTests: XCTestCase {
  private func profile(name: String, email: String = "dev@example.com") -> Profile {
    Profile(name: name, role: "iOS Developer", email: email, city: "Subang", course: "iOS Expert", photoAssetName: "photo")
  }

  func testInitials_takesFirstTwoWords() {
    XCTAssertEqual(profile(name: "fikry andias praja").initials, "FA")
    XCTAssertEqual(profile(name: "Fikry").initials, "F")
    XCTAssertEqual(profile(name: "").initials, "")
  }

  func testEmailURL_usesMailtoScheme() {
    XCTAssertEqual(profile(name: "A").emailURL?.absoluteString, "mailto:dev@example.com")
  }
}
