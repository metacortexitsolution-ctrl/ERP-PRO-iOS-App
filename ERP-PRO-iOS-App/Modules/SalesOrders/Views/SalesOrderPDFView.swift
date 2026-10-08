//
//  SalesOrderPDFView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// PDF Preview Sheet for Sales Orders.
public struct SalesOrderPDFPreviewView: View {
    let order: SalesOrder
    @Environment(\.dismiss) private var dismiss

    public init(order: SalesOrder) {
        self.order = order
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("Sales Order PDF Document")
                    .font(.title2)
                    .bold()

                Text("\(order.orderId) • \(order.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let po = order.poReference {
                    Text("PO Reference: \(po)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("Total: \(order.formattedTotal)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .navigationTitle("Sales Order PDF")
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
