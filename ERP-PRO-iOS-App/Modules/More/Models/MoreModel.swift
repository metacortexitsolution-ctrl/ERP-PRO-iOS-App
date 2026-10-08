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
    public let destination: SidebarDestination?

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        iconName: String,
        tintColor: Color,
        badgeText: String? = nil,
        badgeColor: Color? = nil,
        isFullWidth: Bool = false,
        destination: SidebarDestination? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.tintColor = tintColor
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.isFullWidth = isFullWidth
        self.destination = destination
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
                    MoreModuleItem(title: "Orders", subtitle: "Sales pipeline", iconName: "cart", tintColor: .blue, destination: .orders),
                    MoreModuleItem(title: "Quotations", subtitle: "Quotations & bids", iconName: "doc.text", tintColor: .blue, destination: .estimates),
                    MoreModuleItem(title: "Delivery Challans", subtitle: "Delivery dispatch", iconName: "truck.box", tintColor: .blue, destination: .challans),
                    MoreModuleItem(title: "Credit Notes", subtitle: "Sales return memos", iconName: "doc.badge.plus", tintColor: .blue, destination: .creditNotes)
                ]
            ),
            MoreSection(
                title: "PURCHASES",
                items: [
                    MoreModuleItem(title: "Purchase Orders", subtitle: "Procurement POs", iconName: "doc.badge.gearshape", tintColor: .purple, destination: .purchaseOrders),
                    MoreModuleItem(title: "Bills", subtitle: "Inward payables", iconName: "doc.plaintext", tintColor: .purple, destination: .bills),
                    MoreModuleItem(title: "Debit Notes", subtitle: "Purchase return", iconName: "doc.badge.arrow.up", tintColor: .purple, destination: .debitNotes),
                    MoreModuleItem(title: "Vendors", subtitle: "Supplier directory", iconName: "storefront", tintColor: .purple, destination: .vendors)
                ]
            ),
            MoreSection(
                title: "INVENTORY",
                items: [
                    MoreModuleItem(title: "Products", subtitle: "Items & catalog", iconName: "shippingbox", tintColor: .green, destination: .products),
                    MoreModuleItem(title: "Inventory", subtitle: "Stock & warehouses", iconName: "building.columns", tintColor: .green, destination: .inventory)
                ]
            ),
            MoreSection(
                title: "FINANCE",
                items: [
                    MoreModuleItem(title: "Expenses", subtitle: "Claims & cash flows", iconName: "creditcard", tintColor: .indigo, destination: .expenses),
                    MoreModuleItem(title: "Bank Reconciliation", subtitle: "Bank statements", iconName: "building.columns.fill", tintColor: .indigo, destination: .reconciliation),
                    MoreModuleItem(title: "Revenue Recognition", subtitle: "Deferred & realized", iconName: "chart.line.uptrend.xyaxis", tintColor: .indigo, destination: .revenueRec)
                ]
            ),
            MoreSection(
                title: "CUSTOMERS",
                items: [
                    MoreModuleItem(title: "Customers", subtitle: "Client directory", iconName: "person.2", tintColor: .blue, destination: .customers),
                    MoreModuleItem(title: "Companies", subtitle: "Branches & units", iconName: "building.2", tintColor: .blue, destination: .companies)
                ]
            ),
            MoreSection(
                title: "GST & TAX",
                items: [
                    MoreModuleItem(title: "Tax Compliance", subtitle: "GSTR-1 & liability", iconName: "tablecells", tintColor: .orange, destination: .taxCompliance),
                    MoreModuleItem(title: "GST Summary", subtitle: "Tax filing overview", iconName: "chart.pie", tintColor: .orange, destination: .gstSummary)
                ]
            ),
            MoreSection(
                title: "REPORTS",
                items: [
                    MoreModuleItem(title: "Executive Summary", subtitle: "Key business KPIs", iconName: "chart.bar.doc.horizontal", tintColor: .teal, destination: .execSummary),
                    MoreModuleItem(title: "Profit & Loss", subtitle: "Income & expenses", iconName: "chart.line.uptrend.xyaxis", tintColor: .teal, destination: .profitAndLoss),
                    MoreModuleItem(title: "Balance Sheet", subtitle: "Assets & liabilities", iconName: "scales", tintColor: .teal, destination: .balanceSheet),
                    MoreModuleItem(title: "Cash Flow", subtitle: "Inflows & outflows", iconName: "arrow.triangle.2.circlepath", tintColor: .teal, destination: .cashFlow),
                    MoreModuleItem(title: "AR Aging", subtitle: "Receivables aging", iconName: "clock.arrow.circlepath", tintColor: .teal, destination: .arAging),
                    MoreModuleItem(title: "GST Report", subtitle: "GSTR audit logs", iconName: "doc.badge.gearshape", tintColor: .teal, destination: .gstReport),
                    MoreModuleItem(title: "Expense Report", subtitle: "Category breakdown", iconName: "doc.plaintext.fill", tintColor: .teal, destination: .expenseReport),
                    MoreModuleItem(title: "Payment Report", subtitle: "Receipt & payout logs", iconName: "creditcard.fill", tintColor: .teal, destination: .paymentReport),
                    MoreModuleItem(title: "Invoice Report", subtitle: "Billing breakdown", iconName: "doc.text.fill", tintColor: .teal, destination: .invoiceReport),
                    MoreModuleItem(title: "MRR Report", subtitle: "Recurring revenue", iconName: "chart.xyaxis.line", tintColor: .teal, destination: .mrrReport)
                ]
            )
        ]
    }
}
