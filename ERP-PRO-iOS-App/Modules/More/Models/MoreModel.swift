//
//  MoreModel.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct MoreModuleItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let iconName: String
    public let tintColor: Color
    public let badgeText: String?
    public let badgeColor: Color?
    public let isFullWidth: Bool

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        iconName: String,
        tintColor: Color,
        badgeText: String? = nil,
        badgeColor: Color? = nil,
        isFullWidth: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.tintColor = tintColor
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.isFullWidth = isFullWidth
    }
}

public struct MoreSection: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let actionTitle: String?
    public let items: [MoreModuleItem]

    public init(
        id: String = UUID().uuidString,
        title: String,
        actionTitle: String? = nil,
        items: [MoreModuleItem]
    ) {
        self.id = id
        self.title = title
        self.actionTitle = actionTitle
        self.items = items
    }
}

public struct MoreMockData {
    public static var sections: [MoreSection] {
        [
            MoreSection(
                title: "SALES",
                items: [
                    MoreModuleItem(title: "Orders", subtitle: "Sales pipeline", iconName: "cart", tintColor: .blue),
                    MoreModuleItem(title: "Quotations", subtitle: "Quotations & bids", iconName: "doc.text", tintColor: .blue),
                    MoreModuleItem(title: "Delivery Challans", subtitle: "Delivery dispatch", iconName: "truck.box", tintColor: .blue),
                    MoreModuleItem(title: "Credit Notes", subtitle: "Sales return memos", iconName: "doc.badge.plus", tintColor: .blue)
                ]
            ),
            MoreSection(
                title: "PURCHASES",
                items: [
                    MoreModuleItem(title: "Purchase Orders", subtitle: "Procurement POs", iconName: "doc.badge.gearshape", tintColor: .purple),
                    MoreModuleItem(title: "Bills", subtitle: "Inward payables", iconName: "doc.plaintext", tintColor: .purple),
                    MoreModuleItem(title: "Debit Notes", subtitle: "Purchase return", iconName: "doc.badge.arrow.up", tintColor: .purple),
                    MoreModuleItem(title: "Vendors", subtitle: "Supplier directory", iconName: "storefront", tintColor: .purple)
                ]
            ),
            MoreSection(
                title: "INVENTORY",
                items: [
                    MoreModuleItem(title: "Products", subtitle: "Items & catalog", iconName: "shippingbox", tintColor: .green),
                    MoreModuleItem(title: "Inventory", subtitle: "Stock & warehouses", iconName: "building.columns", tintColor: .green)
                ]
            ),
            MoreSection(
                title: "FINANCE",
                items: [
                    MoreModuleItem(title: "Expenses", subtitle: "Claims & cash flows", iconName: "creditcard", tintColor: .indigo),
                    MoreModuleItem(title: "Bank Reconciliation", subtitle: "Bank statements", iconName: "building.columns.fill", tintColor: .indigo),
                    MoreModuleItem(title: "Revenue Recognition", subtitle: "Deferred & realized", iconName: "chart.line.uptrend.xyaxis", tintColor: .indigo)
                ]
            ),
            MoreSection(
                title: "CUSTOMERS",
                items: [
                    MoreModuleItem(title: "Customers", subtitle: "Client directory", iconName: "person.2", tintColor: .blue),
                    MoreModuleItem(title: "Companies", subtitle: "Branches & units", iconName: "building.2", tintColor: .blue)
                ]
            ),
            MoreSection(
                title: "GST & TAX",
                items: [
                    MoreModuleItem(title: "Tax Compliance", subtitle: "GSTR-1 & liability", iconName: "tablecells", tintColor: .orange),
                    MoreModuleItem(title: "GST Summary", subtitle: "Tax filing overview", iconName: "chart.pie", tintColor: .orange)
                ]
            ),
            MoreSection(
                title: "REPORTS",
                items: [
                    MoreModuleItem(title: "Executive Summary", subtitle: "Key business KPIs", iconName: "chart.bar.doc.horizontal", tintColor: .teal),
                    MoreModuleItem(title: "Profit & Loss", subtitle: "Income & expenses", iconName: "chart.line.uptrend.xyaxis", tintColor: .teal),
                    MoreModuleItem(title: "Balance Sheet", subtitle: "Assets & liabilities", iconName: "scales", tintColor: .teal),
                    MoreModuleItem(title: "Cash Flow", subtitle: "Inflows & outflows", iconName: "arrow.triangle.2.circlepath", tintColor: .teal),
                    MoreModuleItem(title: "AR Aging", subtitle: "Receivables aging", iconName: "clock.arrow.circlepath", tintColor: .teal),
                    MoreModuleItem(title: "GST Report", subtitle: "GSTR audit logs", iconName: "doc.badge.gearshape", tintColor: .teal),
                    MoreModuleItem(title: "Expense Report", subtitle: "Category breakdown", iconName: "doc.plaintext.fill", tintColor: .teal),
                    MoreModuleItem(title: "Payment Report", subtitle: "Receipt & payout logs", iconName: "creditcard.fill", tintColor: .teal),
                    MoreModuleItem(title: "Invoice Report", subtitle: "Billing breakdown", iconName: "doc.text.fill", tintColor: .teal),
                    MoreModuleItem(title: "MRR Report", subtitle: "Recurring revenue", iconName: "chart.xyaxis.line", tintColor: .teal)
                ]
            )
        ]
    }
}
