//
//  InvoiceFilterView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Main Floating Filter Popover Container managing 8 filter categories with a Single Active Submenu state machine.
public struct InvoiceFilterView: View {
    @ObservedObject var controller: InvoiceController

    @State private var statusSearchText: String = ""
    @State private var customerSearchText: String = ""

    public init(controller: InvoiceController) {
        self.controller = controller
    }

    private var filteredStatuses: [InvoiceStatus] {
        if statusSearchText.isEmpty {
            return InvoiceStatus.allCases
        } else {
            return InvoiceStatus.allCases.filter { $0.rawValue.lowercased().contains(statusSearchText.lowercased()) }
        }
    }

    private var filteredCustomerNames: [String] {
        if customerSearchText.isEmpty {
            return controller.allCustomerNames
        } else {
            return controller.allCustomerNames.filter { $0.lowercased().contains(customerSearchText.lowercased()) }
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 18))
                    Text(ConstantString.filters)
                        .font(.system(size: 16, weight: .bold))

                    if controller.activeFilterCount > 0 {
                        Text("\(controller.activeFilterCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                if controller.activeFilterCount > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            controller.clearAllFilters()
                        }
                    }) {
                        Text(ConstantString.clearAll)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(spacing: 12) {
                    // Active Filter Chips Horizontal Bar
                    if controller.activeFilterCount > 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                if !controller.selectedStatuses.isEmpty {
                                    InvoiceFilterChipPill(label: "Status: \(controller.selectedStatuses.count)") {
                                        controller.selectedStatuses.removeAll()
                                    }
                                }
                                if let preset = controller.selectedDatePreset {
                                    InvoiceFilterChipPill(label: "Date: \(preset.rawValue)") {
                                        controller.selectedDatePreset = nil
                                    }
                                }
                            }
                            .padding(.horizontal, 14)
                        }
                        .padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground))

                        Divider()
                    }

                    // 8 Filter Categories List
                    VStack(spacing: 8) {
                        ForEach(FilterCategory.allCases) { category in
                            categoryRowView(for: category)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.vertical, 10)
            }
        }
        .frame(width: 380, height: 540)
        .background(Color(uiColor: .systemBackground))
    }

    @ViewBuilder
    private func categoryRowView(for category: FilterCategory) -> some View {
        let isOpen = controller.activeFilterCategory == category
        let subtitle = controller.subtitleForCategory(category)

        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    controller.toggleFilterCategory(category)
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 32, height: 32)
                        Image(systemName: category.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isOpen ? "chevron.up" : "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isOpen ? Color.blue.opacity(0.06) : Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)

            if isOpen {
                VStack(spacing: 0) {
                    categorySubmenuView(for: category)
                }
                .padding(12)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(10)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private func categorySubmenuView(for category: FilterCategory) -> some View {
        switch category {
        case .status:
            VStack(alignment: .leading, spacing: 8) {
                ForEach(filteredStatuses) { status in
                    let isSelected = controller.selectedStatuses.contains(status)
                    Button(action: {
                        if isSelected { controller.selectedStatuses.remove(status) }
                        else { controller.selectedStatuses.insert(status) }
                    }) {
                        HStack {
                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(isSelected ? .blue : .secondary)
                            Text(status.rawValue)
                                .font(.system(size: 13))
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        default:
            Text("\(category.rawValue) Options")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct InvoiceFilterChipPill: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.12))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}
