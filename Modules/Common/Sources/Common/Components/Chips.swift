//
//  Chips.swift
//  Common
//

import SwiftUI

/// Chip yang bisa dipilih (filter genre di Beranda).
public struct SelectableChip: View {
  private let title: String
  private let isSelected: Bool
  private let action: () -> Void

  public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
    self.title = title
    self.isSelected = isSelected
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .foregroundStyle(isSelected ? Color.white : Color.primary)
        .background(
          Capsule().fill(isSelected ? Color.accentColor : Color(.secondarySystemFill))
        )
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

/// Chip statis untuk label (genre & platform di Detail).
public struct TagChip: View {
  private let title: String

  public init(title: String) {
    self.title = title
  }

  public var body: some View {
    Text(title)
      .font(.footnote.weight(.medium))
      .padding(.horizontal, 11)
      .padding(.vertical, 6)
      .background(Capsule().fill(Color(.secondarySystemFill)))
  }
}

/// Layout yang otomatis memindahkan item ke baris berikutnya bila lebar tidak cukup.
public struct FlowLayout: Layout {
  private let spacing: CGFloat

  public init(spacing: CGFloat = 8) {
    self.spacing = spacing
  }

  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = arrange(subviews: subviews, maxWidth: proposal.width ?? .infinity)
    let height = rows.last.map { $0.originY + $0.height } ?? 0
    let width = rows.map(\.width).max() ?? 0
    return CGSize(width: width, height: height)
  }

  public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    for row in arrange(subviews: subviews, maxWidth: bounds.width) {
      var originX = bounds.minX
      for index in row.indices {
        let size = subviews[index].sizeThatFits(.unspecified)
        subviews[index].place(
          at: CGPoint(x: originX, y: bounds.minY + row.originY),
          proposal: ProposedViewSize(size)
        )
        originX += size.width + spacing
      }
    }
  }

  private struct Row {
    var indices: [Int] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
    var originY: CGFloat = 0
  }

  private func arrange(subviews: Subviews, maxWidth: CGFloat) -> [Row] {
    var rows: [Row] = []
    var current = Row()

    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let nextWidth = current.indices.isEmpty ? size.width : current.width + spacing + size.width

      if nextWidth > maxWidth, !current.indices.isEmpty {
        rows.append(current)
        current = Row(indices: [index], width: size.width, height: size.height,
                      originY: current.originY + current.height + spacing)
      } else {
        current.indices.append(index)
        current.width = nextWidth
        current.height = max(current.height, size.height)
      }
    }
    if !current.indices.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
