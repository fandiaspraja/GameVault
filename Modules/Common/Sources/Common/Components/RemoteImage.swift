//
//  RemoteImage.swift
//  Common
//

import Kingfisher
import SwiftUI

/// Gambar dari URL (Kingfisher, dengan cache) yang selalu mengisi bingkainya.
/// Bila `url` gagal dimuat, otomatis mencoba `fallbackURL` (mis. gambar asli tanpa crop).
public struct RemoteImage: View {
  private let url: URL?
  private let fallbackURL: URL?
  private let contentMode: SwiftUI.ContentMode
  private let background: Color

  @State private var useFallback = false

  public init(
    url: URL?,
    fallbackURL: URL? = nil,
    contentMode: SwiftUI.ContentMode = .fill,
    background: Color = Color(.secondarySystemBackground)
  ) {
    self.url = url
    self.fallbackURL = fallbackURL
    self.contentMode = contentMode
    self.background = background
  }

  private var currentURL: URL? {
    useFallback ? fallbackURL : url
  }

  public var body: some View {
    background
      .overlay {
        if let currentURL {
          KFImage(currentURL)
            .placeholder { placeholder }
            .onFailure { _ in
              if !useFallback, let fallbackURL, fallbackURL != url {
                useFallback = true
              }
            }
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: contentMode)
        } else {
          placeholder
        }
      }
      .clipped()
      .accessibilityHidden(true)
  }

  private var placeholder: some View {
    Image(systemName: "photo")
      .font(.title2)
      .foregroundStyle(.tertiary)
  }
}
