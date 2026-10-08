//
//  InvoicePDFView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// PDF Preview sheet for Invoices.
public struct InvoicePDFPreviewView: View {
    let invoice: Invoice
    @Environment(\.dismiss) private var dismiss

    public init(invoice: Invoice) {
        self.invoice = invoice
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Invoice PDF Document")
                    .font(.title2)
                    .bold()

                Text("\(invoice.invoiceId) • \(invoice.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Total: \(invoice.formattedTotal)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .navigationTitle(ConstantString.invoicePDF)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

/// POS Thermal Receipt View for Invoices.
public struct InvoiceThermalPrintView: View {
    let invoice: Invoice
    @Environment(\.dismiss) private var dismiss

    public init(invoice: Invoice) {
        self.invoice = invoice
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "printer.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.orange)

                Text("POS Thermal Receipt Preview")
                    .font(.title3)
                    .bold()

                VStack(spacing: 4) {
                    Text("--------------------------------")
                    Text("META CORTEX SOLUTIONS")
                        .bold()
                    Text("Receipt #: \(invoice.invoiceId)")
                    Text("Customer: \(invoice.customerName)")
                    Text("Date: \(invoice.formattedIssueDate)")
                    Text("TOTAL: \(invoice.formattedTotal)")
                        .bold()
                    Text("--------------------------------")
                }
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(uiColor: .tertiarySystemFill))
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationTitle(ConstantString.posThermalReceipt)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Print") { dismiss() }
                        .font(.headline)
                }
            }
        }
    }
}
