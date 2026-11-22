//
//  AboutView.swift
//  About
//

import Common
import SwiftUI
import UIKit

public struct AboutView: View {
  private let profile: Profile
  private let appVersion: String
  @Environment(\.openURL) private var openURL

  public init(profile: Profile, appVersion: String) {
    self.profile = profile
    self.appVersion = appVersion
  }

  public var body: some View {
    List {
      Section {
        header
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .listRowBackground(Color.clear)
      }

      Section(L10n.About.profileSection) {
        if let emailURL = profile.emailURL {
          Link(destination: emailURL) {
            InfoRow(systemImage: "envelope.fill", title: L10n.About.email, value: profile.email)
          }
          .foregroundStyle(.primary)
        }
        InfoRow(systemImage: "mappin.and.ellipse", title: L10n.About.city, value: profile.city)
        InfoRow(systemImage: "book.fill", title: L10n.About.course, value: profile.course)
      }

      Section {
        InfoRow(systemImage: "info.circle.fill", title: L10n.About.version, value: appVersion)
        if let url = URL(string: "https://rawg.io") {
          Link(destination: url) {
            InfoRow(systemImage: "globe", title: L10n.About.dataSource, value: "RAWG.io")
          }
          .foregroundStyle(.primary)
        }
        Button {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
          }
        } label: {
          InfoRow(systemImage: "character.bubble.fill", title: L10n.About.language, value: languageName)
        }
        .foregroundStyle(.primary)
      } header: {
        Text(L10n.About.appSection)
      } footer: {
        Text(L10n.About.languageHint)
      }
    }
    .listStyle(.insetGrouped)
    .navigationTitle(L10n.About.title)
  }

  private var header: some View {
    VStack(spacing: 8) {
      Image(profile.photoAssetName)
        .resizable()
        .scaledToFill()
        .frame(width: 124, height: 124)
        .background(Circle().fill(Color(.secondarySystemFill)))
        .clipShape(Circle())
        .overlay(Circle().stroke(Color(.separator), lineWidth: 0.5))
        .accessibilityLabel(L10n.About.photo(profile.name))
        .padding(.bottom, 8)

      Text(profile.name)
        .font(.title2.bold())
        .multilineTextAlignment(.center)

      Text(profile.role)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  private var languageName: String {
    L10n.locale.localizedString(forLanguageCode: L10n.languageCode)?.capitalized(with: L10n.locale)
      ?? L10n.languageCode
  }
}

private struct InfoRow: View {
  let systemImage: String
  let title: String
  let value: String

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: systemImage)
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .frame(width: 28, height: 28)
        .background(RoundedRectangle(cornerRadius: 7, style: .continuous).fill(Color.accentColor))
      Text(title)
      Spacer(minLength: 8)
      Text(value)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.trailing)
    }
    .accessibilityElement(children: .combine)
  }
}
