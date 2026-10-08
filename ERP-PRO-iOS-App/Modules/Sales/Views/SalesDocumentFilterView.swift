//
//  SalesDocumentFilterView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Shared Floating Filter Popover Container managing 8 filter categories with a Single Active Submenu state machine.
public struct SalesDocumentFilterView: View {
    @ObservedObject var controller: SalesDocumentController

    @State private var statusSearchText: String = ""

    public init(controller: SalesDocumentController) {
        self.controller = controller
    }

    private var filteredStatuses: [SalesDocumentStatus] {
        if statusSearchText.isEmpty {
            return SalesDocumentStatus.allCases
        } else {
            return SalesDocumentStatus.allCases.filter { $0.rawValue.lowercased().contains(statusSearchText.lowercased()) }
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
                            let isSelected = controller.selectedStatuses.contains(status)
                            let count = controller.documents.filter { $0.status == status }.count

                            Button(action: {
                                if isSelected { controller.selectedStatuses.remove(status) }
                                else { controller.selectedStatuses.insert(status) }
                            }) {
                                HStack {
                                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isSelected ? .blue : .secondary)

                                    SalesDocumentStatusBadgeView(status: status)

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
