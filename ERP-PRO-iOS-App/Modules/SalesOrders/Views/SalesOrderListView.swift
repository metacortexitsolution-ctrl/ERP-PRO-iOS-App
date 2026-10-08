//
//  SalesOrderListView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

/// Sales Orders Pipeline view delegating to the unified SalesDocumentListView engine.
public struct SalesOrderListView: View {
    public init() {}

    public var body: some View {
        SalesDocumentListView(documentType: .salesOrder)
    }
}
