//
//  MoreView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct MoreView: View {
    @StateObject private var controller = MoreController()

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("Search modules (e.g. gst, vendor, stock...)", text: $controller.searchText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.primary)

                    if !controller.searchText.isEmpty {
                        Button {
                            controller.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(CommonColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CommonColor.cardBorder, lineWidth: 0.8)
                )

                // Categorized Sections
                if controller.sections.isEmpty {
                    emptySearchState
                } else {
                    ForEach(controller.sections) { section in
                        MoreSectionView(section: section)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(CommonColor.background)
        .navigationTitle("More")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        // Notification Bell
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Button {
                        // Profile Avatar
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 26, height: 26)
                            Image(systemName: "person.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty Search State
    private var emptySearchState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding(.top, 32)

            Text("No modules found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)

            Text("Try searching with different keywords like 'bills', 'inventory', or 'tax'.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - Section View Component
struct MoreSectionView: View {
    let section: MoreSection

    private var gridItems: [MoreModuleItem] {
        section.items.filter { !$0.isFullWidth }
    }

    private var fullWidthItems: [MoreModuleItem] {
        section.items.filter { $0.isFullWidth }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section Header
            HStack {
                Text(section.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)

                Spacer()

                if let actionTitle = section.actionTitle {
                    Button(actionTitle) {
                        // Section action
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
                }
            }

            // 2-Column Grid Items
            if !gridItems.isEmpty {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(gridItems) { item in
                        MoreModuleCard(item: item)
                    }
                }
            }

            // Full Width Items
            if !fullWidthItems.isEmpty {
                VStack(spacing: 10) {
                    ForEach(fullWidthItems) { item in
                        MoreModuleCard(item: item)
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}
