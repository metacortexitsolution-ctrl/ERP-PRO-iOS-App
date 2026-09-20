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
                title: "SALES & BILLING",
                items: [
                    MoreModuleItem(title: "Orders", subtitle: "Sales pipeline", iconName: "bag.fill", tintColor: .blue),
                    MoreModuleItem(title: "Estimates", subtitle: "Quotations & bids", iconName: "doc.text.fill", tintColor: .blue),
                    MoreModuleItem(title: "Challans", subtitle: "Delivery dispatch", iconName: "truck.box.fill", tintColor: .blue),
                    MoreModuleItem(title: "Credit Notes", subtitle: "Sales return memos", iconName: "doc.badge.plus", tintColor: .blue)
                ]
            ),
            MoreSection(
                title: "PURCHASES & ACCOUNTS PAYABLE",
                items: [
                    MoreModuleItem(title: "Purchase Orders", subtitle: "Procurement POs", iconName: "cart.fill", tintColor: .purple),
                    MoreModuleItem(title: "Vendor Bills", subtitle: "Inward payables", iconName: "doc.text.fill", tintColor: .purple),
                    MoreModuleItem(title: "Debit Notes", subtitle: "Purchase return", iconName: "doc.badge.arrow.up", tintColor: .purple),
                    MoreModuleItem(title: "Vendors", subtitle: "Supplier directory", iconName: "building.2.fill", tintColor: .purple)
                ]
            ),
            MoreSection(
                title: "INVENTORY & PRODUCTS",
                items: [
                    MoreModuleItem(title: "Products Master", subtitle: "Items & pricing", iconName: "shippingbox.fill", tintColor: .green),
                    MoreModuleItem(title: "Inventory Control", subtitle: "Stock & warehouses", iconName: "building.columns.fill", tintColor: .green)
                ]
            ),
            MoreSection(
                title: "FINANCIALS & ACCOUNTING",
                items: [
                    MoreModuleItem(title: "Expenses", subtitle: "Claims & cash flows", iconName: "creditcard.fill", tintColor: Color.indigo),
                    MoreModuleItem(title: "Reconciliation", subtitle: "Bank statements", iconName: "building.columns.fill", tintColor: Color.indigo),
                    MoreModuleItem(title: "Revenue Rec.", subtitle: "Deferred & realized", iconName: "chart.line.uptrend.xyaxis", tintColor: .green, isFullWidth: true)
                ]
            ),
            MoreSection(
                title: "CONTACTS",
                items: [
                    MoreModuleItem(title: "Customers", subtitle: "Client directory", iconName: "person.2.fill", tintColor: .blue),
                    MoreModuleItem(title: "Vendors", subtitle: "Supplier directory", iconName: "storefront.fill", tintColor: .purple)
                ]
            ),
            MoreSection(
                title: "ORGANIZATION",
                items: [
                    MoreModuleItem(title: "Customer Portal", subtitle: "Debtors & terms", iconName: "person.2.fill", tintColor: .blue),
                    MoreModuleItem(title: "Multi-Company", subtitle: "Branches & units", iconName: "building.2.fill", tintColor: .purple)
                ]
            ),
            MoreSection(
                title: "GST & TAX",
                items: [
                    MoreModuleItem(
                        title: "Tax Compliance & ...",
                        subtitle: "GSTR-1, GSTR-3B & tax liability",
                        iconName: "tablecells.fill",
                        tintColor: .green,
                        badgeText: "Auto-GST",
                        badgeColor: .green,
                        isFullWidth: true
                    )
                ]
            ),
            MoreSection(
                title: "REPORTS & ANALYTICS",
                items: [
                    MoreModuleItem(
                        title: "Reports & Analytics",
                        subtitle: "View financial, rece...",
                        iconName: "chart.xyaxis.line",
                        tintColor: .blue,
                        badgeText: "10 Reports",
                        badgeColor: .blue,
                        isFullWidth: true
                    )
                ]
            )
        ]
    }
}
