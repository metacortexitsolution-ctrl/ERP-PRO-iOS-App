//
//  SalesDocumentPDFView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Shared PDF preview sheet component.
public struct SalesDocumentPDFPreviewView: View {
    let document: SalesDocument
    @Environment(\.dismiss) private var dismiss

    public init(document: SalesDocument) {
        self.document = document
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: document.documentType.systemIcon)
                    .font(.system(size: 64))
                    .foregroundColor(.blue)

                Text("\(document.documentType.rawValue) PDF Document")
                    .font(.title2)
                    .bold()

                Text("\(document.documentId) • \(document.customerName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Total: \(document.formattedTotal)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
            .navigationTitle("\(document.documentType.rawValue) PDF")
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
