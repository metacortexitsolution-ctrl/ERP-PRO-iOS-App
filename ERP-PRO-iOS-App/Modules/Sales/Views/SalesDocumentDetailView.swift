//
//  SalesDocumentDetailView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Shared Inspector View for inspecting document details, line items, PO references, customer info, and quick actions.
public struct SalesDocumentDetailView: View {
    @ObservedObject var controller: SalesDocumentController
    let document: SalesDocument

    public init(controller: SalesDocumentController, document: SalesDocument) {
        self.controller = controller
        self.document = document
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(document.documentId)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.blue)

                            Text(document.companyName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        SalesDocumentStatusBadgeView(status: document.status)
                    }

                    Divider()

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(document.documentType == .invoice ? "ISSUE DATE" : "ORDER DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(document.formattedPrimaryDate)
                                .font(.system(size: 13, weight: .semibold))
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(document.documentType == .invoice ? "DUE DATE" : "DELIVERY DATE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(document.formattedSecondaryDate)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(document.isOverdue ? .red : .primary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("TOTAL AMOUNT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(document.formattedTotal)
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

                    Text(document.customerName)
                        .font(.system(size: 16, weight: .bold))

                    if let email = document.customerEmail {
                        Label(email, systemImage: "envelope.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if let phone = document.customerPhone {
                        Label(phone, systemImage: "phone.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    if let po = document.poReference {
                        Label("PO Reference: \(po)", systemImage: "doc.text")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Line Items
                VStack(alignment: .leading, spacing: 10) {
                    Text(ConstantString.itemizedBreakdown)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    if document.items.isEmpty {
                        Text("No line items attached.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(document.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Qty: \(String(format: "%.0f", item.quantity)) × ₹\(String(format: "%.2f", item.rate))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(CommonCurrencyFormatter.format(item.amount, currencyCode: document.currency))
                                    .font(.system(size: 14, weight: .bold))
                            }
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)

                // Actions
                HStack(spacing: 12) {
                    Button(action: { controller.isShowingPDFPreview = true }) {
                        Label("View PDF", systemImage: "doc.richtext")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    if document.documentType == .salesOrder {
                        Button(action: {
                            withAnimation {
                                controller.updateStatus(for: document, newStatus: .invoiced)
                                controller.toastMessage = "Order \(document.documentId) converted to Invoice!"
                            }
                        }) {
                            Label("Convert to Invoice", systemImage: "doc.text.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle(document.documentId)
        .navigationBarTitleDisplayMode(.inline)
    }
}
