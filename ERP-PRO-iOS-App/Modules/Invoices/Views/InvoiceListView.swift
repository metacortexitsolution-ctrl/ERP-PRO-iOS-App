//
//  InvoiceListView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Accounts Receivable & Invoice management view delegating to the unified SalesDocumentListView engine.
public struct InvoiceListView: View {
    public init() {}

    public var body: some View {
        SalesDocumentListView(documentType: .invoice)
    }
}
