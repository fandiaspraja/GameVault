//
//  StateViews.swift
//  Common
//
//  Tampilan untuk kondisi loading, error, dan kosong.
//

import SwiftUI

public struct EmptyStateView: View {
  private let systemImage: String
  private let title: String
  private let message: String

  public init(systemImage: String, title: String, message: String) {
    self.systemImage = systemImage
    self.title = title
    self.message = message
  }

  public var body: some View {
    VStack(spacing: 10) {
      Image(systemName: systemImage)
        .font(.system(size: 44, weight: .regular))
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)
      Text(title)
        .font(.headline)
      Text(message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, 32)
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}

public struct ErrorStateView: View {
  private let message: String
  private let retry: () -> Void

  public init(message: String, retry: @escaping () -> Void) {
    self.message = message
    self.retry = retry
  }

  public var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 44, weight: .regular))
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)
      Text(L10n.General.loadFailed)
        .font(.headline)
      Text(message)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
      Button(action: retry) {
        Label(L10n.General.retry, systemImage: "arrow.clockwise")
          .font(.body.weight(.semibold))
          .padding(.horizontal, 8)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(.top, 6)
    }
    .padding(.horizontal, 32)
    .frame(maxWidth: .infinity)
  }
}

/// Kerangka baris dengan efek shimmer, ditampilkan saat data pertama kali dimuat.
public struct SkeletonRowView: View {
  public init() {}

  public var body: some View {
    HStack(spacing: 12) {
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .frame(width: 104, height: 72)
      VStack(alignment: .leading, spacing: 8) {
        RoundedRectangle(cornerRadius: 4).frame(width: 170, height: 14)
        RoundedRectangle(cornerRadius: 4).frame(width: 120, height: 11)
        RoundedRectangle(cornerRadius: 4).frame(width: 50, height: 11)
      }
      Spacer(minLength: 0)
    }
    .foregroundStyle(Color(.systemGray5))
    .padding(.vertical, 6)
    .shimmering()
    .accessibilityHidden(true)
  }
}

/// Notifikasi singkat di bagian bawah layar.
public struct ToastView: View {
  private let message: String
  private let systemImage: String

  public init(message: String, systemImage: String) {
    self.message = message
    self.systemImage = systemImage
  }

  public var body: some View {
    Label(message, systemImage: systemImage)
      .font(.subheadline.weight(.semibold))
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.regularMaterial, in: Capsule())
      .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
  }
}

private struct ShimmerModifier: ViewModifier {
  @State private var phase: CGFloat = -1

  func body(content: Content) -> some View {
    content
      .overlay {
        GeometryReader { proxy in
          LinearGradient(
            colors: [.clear, .white.opacity(0.45), .clear],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: proxy.size.width * 0.6)
          .offset(x: phase * proxy.size.width)
        }
        .mask { content }
      }
      .onAppear {
        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
          phase = 1.4
        }
      }
  }
}

public extension View {
  func shimmering() -> some View {
    modifier(ShimmerModifier())
  }
}
