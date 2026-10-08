//
//  SalesOrderFilterView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Floating Filter Popover for Sales Orders matching the Invoice 8-category accordion filter design.
public struct SalesOrderFilterView: View {
    @ObservedObject var viewModel: SalesOrderViewModel

    @State private var statusSearchText: String = ""

    public init(viewModel: SalesOrderViewModel) {
        self.viewModel = viewModel
    }

    private var filteredStatuses: [SalesOrderStatus] {
        if statusSearchText.isEmpty {
            return SalesOrderStatus.allCases
        } else {
            return SalesOrderStatus.allCases.filter { $0.rawValue.lowercased().contains(statusSearchText.lowercased()) }
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

                    if viewModel.activeFilterCount > 0 {
                        Text("\(viewModel.activeFilterCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                if viewModel.activeFilterCount > 0 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.clearAllFilters()
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
                    // Status Filter Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status Filter")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 13))
                            TextField("Search status...", text: $statusSearchText)
                                .font(.system(size: 13))
                        }
                        .padding(6)
                        .background(Color(uiColor: .tertiarySystemFill))
                        .cornerRadius(8)

                        ForEach(filteredStatuses) { status in
                            let isSelected = viewModel.selectedStatuses.contains(status)
                            let count = viewModel.orders.filter { $0.status == status }.count

                            Button(action: {
                                if isSelected { viewModel.selectedStatuses.remove(status) }
                                else { viewModel.selectedStatuses.insert(status) }
                            }) {
                                HStack {
                                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isSelected ? .blue : .secondary)
                                    SalesOrderStatusBadgeView(status: status)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 3)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(10)
                }
                .padding(12)
            }
        }
        .frame(width: 360, height: 480)
        .background(Color(uiColor: .systemBackground))
    }
}
