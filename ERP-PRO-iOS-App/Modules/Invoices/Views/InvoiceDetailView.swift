//
//  InvoiceDetailView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Detailed Inspector view displaying invoice breakdown, itemized list, payments, and actions toolbar.
public struct InvoiceDetailView: View {
    @ObservedObject var controller: InvoiceController
    let invoice: Invoice

    public init(controller: InvoiceController, invoice: Invoice) {
        self.controller = controller
        self.invoice = invoice
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Document Header Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(invoice.invoiceId)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.blue)

                            Text(invoice.companyName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        InvoiceStatusBadge(status: invoice.status)
                    }

                    Divider()

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ISSUE DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(invoice.formattedIssueDate)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("DUE DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(invoice.formattedDueDate)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(invoice.isOverdue ? .red : .primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("TOTAL AMOUNT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(invoice.formattedTotal)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Customer Info Card
                VStack(alignment: .leading, spacing: 8) {
                    Text(ConstantString.billTo)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    Text(invoice.customerName)
                        .font(.system(size: 16, weight: .bold))

                    if let email = invoice.customerEmail {
                        Label(email, systemImage: "envelope.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if let phone = invoice.customerPhone {
                        Label(phone, systemImage: "phone.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Itemized Breakdown Table
                VStack(alignment: .leading, spacing: 10) {
                    Text(ConstantString.itemizedBreakdown)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    ForEach(invoice.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Qty: \(String(format: "%.0f", item.quantity)) × ₹\(String(format: "%.2f", item.rate))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(CommonCurrencyFormatter.format(item.amount, currencyCode: invoice.currency))
                                .font(.system(size: 14, weight: .bold))
                        }
                        Divider()
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Actions Bar
                HStack(spacing: 12) {
                    Button(action: { controller.isShowingPDFPreview = true }) {
                        Label("View PDF", systemImage: "doc.richtext")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { controller.isShowingThermalPrintSheet = true }) {
                        Label("Thermal Receipt", systemImage: "printer.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(16)
        }
        .navigationTitle(invoice.invoiceId)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Invoice Status Badge Component

public struct InvoiceStatusBadge: View {
    public let status: InvoiceStatus

    public init(status: InvoiceStatus) {
        self.status = status
    }

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

