//
//  DetailView.swift
//  Detail
//

import Common
import GameVaultCore
import SwiftUI

public struct DetailView: View {
  @StateObject private var presenter: DetailPresenter
  @State private var isDescriptionExpanded = false
  @State private var galleryStartIndex: GalleryIndex?

  public init(presenter: DetailPresenter) {
    _presenter = StateObject(wrappedValue: presenter)
  }

  public var body: some View {
    Group {
      switch presenter.state {
      case .idle, .loading:
        ProgressView(L10n.Detail.loading)
          .frame(maxWidth: .infinity, maxHeight: .infinity)

      case .error(let message):
        ErrorStateView(message: message) { presenter.retry() }
          .frame(maxWidth: .infinity, maxHeight: .infinity)

      case .loaded, .empty:
        if let detail = presenter.item {
          content(detail)
        }
      }
    }
    .navigationTitle(presenter.item?.name ?? L10n.Detail.title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) { favoriteButton }
    }
    .overlay(alignment: .bottom) { toast }
    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: presenter.toastMessage)
    .alert(
      L10n.General.errorTitle,
      isPresented: Binding(
        get: { presenter.alertMessage != nil },
        set: { if !$0 { presenter.dismissAlert() } }
      )
    ) {
      Button(L10n.General.ok, role: .cancel) {}
    } message: {
      Text(presenter.alertMessage ?? "")
    }
    .fullScreenCover(item: $galleryStartIndex) { start in
      ScreenshotGalleryView(screenshots: presenter.screenshots, startIndex: start.value)
    }
    .onAppear { presenter.onAppear() }
  }

  // MARK: - Content

  private func content(_ detail: GameDetailModel) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        RemoteImage(url: detail.imageURL)
          .frame(height: 220)
          .frame(maxWidth: .infinity)

        VStack(alignment: .leading, spacing: 20) {
          header(detail)
          infoCard(detail)

          if !presenter.screenshots.isEmpty {
            screenshotSection
          }
          if !detail.genres.isEmpty {
            tagSection(title: L10n.Detail.genres, tags: detail.genres)
          }
          if !detail.platforms.isEmpty {
            tagSection(title: L10n.Detail.platforms, tags: detail.platforms)
          }

          aboutSection(detail)

          if let website = detail.website {
            Link(destination: website) {
              Label(L10n.Detail.website, systemImage: "safari")
                .font(.body.weight(.semibold))
            }
          }
        }
        .padding(16)
      }
    }
  }

  private func header(_ detail: GameDetailModel) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(detail.name)
        .font(.title2.bold())
        .fixedSize(horizontal: false, vertical: true)

      HStack(spacing: 8) {
        RatingView(rating: detail.rating)
        Text(L10n.Detail.reviews(AppFormatter.count(detail.ratingsCount)))
          .font(.footnote)
          .foregroundStyle(.secondary)

        if let metacritic = detail.metacritic {
          Text("·").foregroundStyle(.secondary)
          MetascoreBadge(score: metacritic)
        }
      }
    }
  }

  private func infoCard(_ detail: GameDetailModel) -> some View {
    HStack(spacing: 0) {
      InfoItem(title: L10n.Detail.release, value: AppFormatter.date(detail.releaseDate))
      Divider()
      InfoItem(title: L10n.Detail.playtime, value: detail.playtime > 0 ? L10n.Detail.playtimeValue(detail.playtime) : "-")
      Divider()
      InfoItem(title: L10n.Detail.developer, value: detail.primaryDeveloper ?? "-")
    }
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color(.secondarySystemBackground))
    )
  }

  private var screenshotSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10n.Detail.screenshots).font(.headline)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          ForEach(Array(presenter.screenshots.enumerated()), id: \.element.id) { index, screenshot in
            Button {
              galleryStartIndex = GalleryIndex(value: index)
            } label: {
                RemoteImage(url: screenshot.imageURL.rawgResized(), fallbackURL: screenshot.imageURL)
                .frame(width: 220, height: 124)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Detail.galleryCounter(index + 1, presenter.screenshots.count))
          }
        }
        .padding(.horizontal, 16)
      }
      .padding(.horizontal, -16)
    }
  }

  private func tagSection(title: String, tags: [String]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title).font(.headline)
      FlowLayout(spacing: 8) {
        ForEach(tags, id: \.self) { TagChip(title: $0) }
      }
    }
  }

  private func aboutSection(_ detail: GameDetailModel) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(L10n.Detail.about).font(.headline)

      Text(detail.about.isEmpty ? L10n.Detail.aboutEmpty : detail.about)
        .font(.body)
        .foregroundStyle(.secondary)
        .lineLimit(isDescriptionExpanded ? nil : 4)
        .fixedSize(horizontal: false, vertical: true)

      if detail.hasLongDescription {
        Button(isDescriptionExpanded ? L10n.Detail.readLess : L10n.Detail.readMore) {
          withAnimation(.easeInOut) { isDescriptionExpanded.toggle() }
        }
        .font(.subheadline.weight(.semibold))
      }
    }
  }

  // MARK: - Toolbar & toast

  private var favoriteButton: some View {
    Button {
      presenter.toggleFavoriteStatus()
    } label: {
      Image(systemName: presenter.isFavorite ? "heart.fill" : "heart")
        .foregroundStyle(presenter.isFavorite ? Color.pink : Color.accentColor)
    }
    .disabled(presenter.item == nil || presenter.isUpdatingFavorite)
    .accessibilityLabel(presenter.isFavorite ? L10n.Detail.removeFavorite : L10n.Detail.addFavorite)
  }

  @ViewBuilder
  private var toast: some View {
    if let message = presenter.toastMessage {
      ToastView(message: message, systemImage: presenter.isFavorite ? "heart.fill" : "heart.slash")
        .padding(.bottom, 24)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
  }
}

/// Pembungkus indeks agar bisa dipakai `fullScreenCover(item:)`.
struct GalleryIndex: Identifiable {
  let value: Int
  var id: Int { value }
}

// MARK: - Subviews

private struct InfoItem: View {
  let title: String
  let value: String

  var body: some View {
    VStack(spacing: 4) {
      Text(title.uppercased(with: L10n.locale))
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
      Text(value)
        .font(.subheadline.weight(.bold))
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.85)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal, 6)
    .accessibilityElement(children: .combine)
  }
}

private struct MetascoreBadge: View {
  let score: Int

  var body: some View {
    HStack(spacing: 4) {
      Text("\(score)")
        .font(.footnote.weight(.bold))
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(color, lineWidth: 1.5))
      Text(L10n.Detail.metascore)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .accessibilityElement(children: .combine)
  }

  private var color: Color {
    switch MetascoreLevel(score: score) {
    case .favorable: return .green
    case .mixed: return .orange
    case .unfavorable: return .red
    }
  }
}
