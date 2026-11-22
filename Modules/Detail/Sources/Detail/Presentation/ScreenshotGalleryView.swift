//
//  ScreenshotGalleryView.swift
//  Detail
//
//  Galeri layar penuh untuk screenshot gim (fitur tambahan submission akhir).
//

import Common
import SwiftUI

struct ScreenshotGalleryView: View {
  let screenshots: [ScreenshotModel]
  @State private var selection: Int
  @Environment(\.dismiss) private var dismiss

  init(screenshots: [ScreenshotModel], startIndex: Int) {
    self.screenshots = screenshots
    _selection = State(initialValue: startIndex)
  }

  var body: some View {
    NavigationStack {
      TabView(selection: $selection) {
        ForEach(Array(screenshots.enumerated()), id: \.element.id) { index, screenshot in
          RemoteImage(url: screenshot.imageURL, contentMode: .fit, background: .black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tag(index)
            .accessibilityLabel(L10n.Detail.galleryCounter(index + 1, screenshots.count))
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .background(Color.black.ignoresSafeArea())
      .navigationTitle(L10n.Detail.galleryCounter(selection + 1, screenshots.count))
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L10n.Detail.close) { dismiss() }
        }
      }
    }
  }
}
