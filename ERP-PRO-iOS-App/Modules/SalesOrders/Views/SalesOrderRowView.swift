//
//  SalesOrderRowView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Custom List Row View for Sales Order Items conforming to native iOS ERP design patterns.
public struct SalesOrderRowView: View {
    let order: SalesOrder
    var viewModel: SalesOrderViewModel
    var isEditingMode: Bool = false
    var onEdit: (() -> Void)? = nil
    var onViewPDF: (() -> Void)? = nil
    var onConvertToInvoice: (() -> Void)? = nil

    public init(
        order: SalesOrder,
        viewModel: SalesOrderViewModel,
        isEditingMode: Bool = false,
        onEdit: (() -> Void)? = nil,
        onViewPDF: (() -> Void)? = nil,
        onConvertToInvoice: (() -> Void)? = nil
    ) {
        self.order = order
        self.viewModel = viewModel
        self.isEditingMode = isEditingMode
        self.onEdit = onEdit
        self.onViewPDF = onViewPDF
        self.onConvertToInvoice = onConvertToInvoice
    }

    private var isSelected: Bool {
        viewModel.selectedOrders.contains(order.orderId)
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Checkbox for Multi-Selection
            if isEditingMode {
                Button(action: { viewModel.toggleSelection(order.orderId) }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .secondary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }

            // Left: Circular Initials Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(order.customerInitials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Center: Order #, Customer Name, Dates
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(order.orderId)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.blue)

                    if let po = order.poReference, !po.isEmpty {
                        Text("(\(po))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Text(order.customerName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text("Date: \(order.formattedOrderDate)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    Text("Deliv: \(order.formattedDeliveryDate)")
                        .font(.system(size: 11, weight: order.isOverdue ? .bold : .regular))
                        .foregroundColor(order.isOverdue ? .red : .secondary)
                }
            }

            Spacer(minLength: 4)

            // Right: Amount & Interactive Status Badge Menu
            VStack(alignment: .trailing, spacing: 4) {
                // Interactive Status Chip Badge with Native SwiftUI Menu
                Menu {
                    Text("Change Order Status")
                        .font(.caption)

                    ForEach(SalesOrderStatus.allCases) { st in
                        Button(action: {
                            withAnimation {
                                viewModel.updateStatus(for: order, newStatus: st)
                            }
                        }) {
                            HStack {
                                Label(st.rawValue, systemImage: st.iconName)
                                if order.status == st {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    SalesOrderStatusBadgeView(status: order.status)
                }

                Text(order.formattedTotal)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                if order.unbilledAmount > 0 {
                    Text("Unbilled: \(order.formattedUnbilled)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation {
                    viewModel.deleteOrder(order)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }

            Button {
                onEdit?()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.gray)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onConvertToInvoice?() ?? viewModel.updateStatus(for: order, newStatus: .invoiced)
            } label: {
                Label("Convert to Invoice", systemImage: "doc.text.fill")
            }
            .tint(.green)

            Button {
                onViewPDF?()
            } label: {
                Label("View PDF", systemImage: "doc.richtext")
            }
            .tint(.blue)
        }
    }
}

// MARK: - Reusable Status Badge Subview

public struct SalesOrderStatusBadgeView: View {
    let status: SalesOrderStatus

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.system(size: 10))
            Text(status.rawValue)
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(status.badgeTextColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.badgeBackgroundColor)
        .clipShape(Capsule())
    }
}
