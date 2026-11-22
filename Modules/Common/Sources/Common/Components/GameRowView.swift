//
//  GameRowView.swift
//  Common
//

import SwiftUI

/// Baris item gim yang dipakai ulang oleh modul Game dan Favorite.
/// Sengaja menerima nilai primitif agar Common tidak bergantung pada model fitur.
public struct GameRowView: View {
  private let title: String
  private let imageURL: URL?
  private let releaseDate: Date?
  private let genre: String?
  private let rating: Double

  public init(title: String, imageURL: URL?, releaseDate: Date?, genre: String?, rating: Double) {
    self.title = title
    self.imageURL = imageURL
    self.releaseDate = releaseDate
    self.genre = genre
    self.rating = rating
  }

  public var body: some View {
    HStack(spacing: 12) {
      RemoteImage(url: imageURL?.rawgResized(), fallbackURL: imageURL)
        .frame(width: 104, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(2)

        Text(subtitle)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)

        RatingView(rating: rating)
      }

      Spacer(minLength: 0)
    }
    .padding(.vertical, 6)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  private var subtitle: String {
    [AppFormatter.date(releaseDate), genre]
      .compactMap { $0 }
      .joined(separator: " · ")
  }
}

public struct RatingView: View {
  private let rating: Double

  public init(rating: Double) {
    self.rating = rating
  }

  public var body: some View {
    HStack(spacing: 3) {
      Image(systemName: "star.fill")
        .foregroundStyle(.orange)
        .imageScale(.small)
      Text(AppFormatter.rating(rating))
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.primary)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(L10n.General.ratingAccessibility(AppFormatter.rating(rating)))
  }
}
