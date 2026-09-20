//
//  MoreModuleCard.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct MoreModuleCard: View {
    let item: MoreModuleItem
    let action: () -> Void

    public init(item: MoreModuleItem, action: @escaping () -> Void = {}) {
        self.item = item
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            if item.isFullWidth {
                fullWidthLayout
            } else {
                gridLayout
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 2-Column Grid Layout
    private var gridLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                // Icon Squircle
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(item.tintColor.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: item.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(item.tintColor)
                }

                Spacer()

                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CommonColor.cardBorder, lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }

    // MARK: - Full Width Layout
    private var fullWidthLayout: some View {
        HStack(spacing: 12) {
            // Icon Squircle
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.tintColor.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: item.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(item.tintColor)
            }

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Optional Badge
            if let badgeText = item.badgeText, let badgeColor = item.badgeColor {
                Text(badgeText)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Trailing Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CommonColor.cardBorder, lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}
