//
//  SalesOrderDetailView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Sales Order Detail Inspector View for inspecting sales order details, line items, PO reference, and performing status transitions.
public struct SalesOrderDetailView: View {
    @ObservedObject var viewModel: SalesOrderViewModel
    let order: SalesOrder

    public init(viewModel: SalesOrderViewModel, order: SalesOrder) {
        self.viewModel = viewModel
        self.order = order
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Summary Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.orderId)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.blue)

                            if let po = order.poReference, !po.isEmpty {
                                Text("PO Reference: \(po)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        SalesOrderStatusBadgeView(status: order.status)
                    }

                    Divider()

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ORDER DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(order.formattedOrderDate)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("DELIVERY DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(order.formattedDeliveryDate)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(order.isOverdue ? .red : .primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("TOTAL AMOUNT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(order.formattedTotal)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Customer Details Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("CUSTOMER DETAILS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    Text(order.customerName)
                        .font(.system(size: 16, weight: .bold))

                    if let email = order.customerEmail {
                        Label(email, systemImage: "envelope.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if let phone = order.customerPhone {
                        Label(phone, systemImage: "phone.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if let sp = order.salesperson {
                        Label("Salesperson: \(sp)", systemImage: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Line Items Breakdown
                VStack(alignment: .leading, spacing: 10) {
                    Text(ConstantString.itemizedBreakdown)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    if order.items.isEmpty {
                        Text("No line items attached.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(order.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Qty: \(String(format: "%.0f", item.quantity)) × ₹\(String(format: "%.2f", item.rate))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(CommonCurrencyFormatter.format(item.amount, currencyCode: order.currency))
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Quick Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.selectedOrder = order
                        viewModel.isShowingPDFPreview = true
                    }) {
                        Label("View PDF", systemImage: "doc.richtext")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        withAnimation {
                            viewModel.updateStatus(for: order, newStatus: .invoiced)
                            viewModel.toastMessage = "Order \(order.orderId) converted to Invoice!"
                        }
                    }) {
                        Label("Convert to Invoice", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
            .padding(16)
        }
        .navigationTitle(order.orderId)
        .navigationBarTitleDisplayMode(.inline)
    }
}
