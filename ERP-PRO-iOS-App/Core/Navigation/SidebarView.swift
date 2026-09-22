//
//  SidebarView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public enum SidebarDestination: String, CaseIterable, Identifiable, Hashable {
    // Top Main
    case dashboard

    // SALES
    case invoices
    case orders
    case estimates
    case challans
    case creditNotes

    // PURCHASES
    case purchaseOrders
    case bills
    case debitNotes
    case vendors

    // INVENTORY
    case products
    case inventory

    // FINANCE
    case payments
    case expenses
    case reconciliation
    case revenueRec

    // CUSTOMERS
    case customers
    case companies

    // GST & TAX
    case taxCompliance
    case gstSummary

    // REPORTS
    case execSummary
    case profitAndLoss
    case balanceSheet
    case cashFlow
    case arAging
    case gstReport
    case expenseReport
    case paymentReport
    case invoiceReport
    case mrrReport

    // ADMINISTRATION
    case users
    case rolesPermissions
    case settings
    case organizationProfile

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: return "Dashboard"

        case .invoices: return "Invoices"
        case .orders: return "Orders"
        case .estimates: return "Quotations"
        case .challans: return "Delivery Challans"
        case .creditNotes: return "Credit Notes"

        case .purchaseOrders: return "Purchase Orders"
        case .bills: return "Bills"
        case .debitNotes: return "Debit Notes"
        case .vendors: return "Vendors"

        case .products: return "Products"
        case .inventory: return "Inventory"

        case .payments: return "Payments & Receipts"
        case .expenses: return "Expenses"
        case .reconciliation: return "Bank Reconciliation"
        case .revenueRec: return "Revenue Recognition"

        case .customers: return "Customers"
        case .companies: return "Companies"

        case .taxCompliance: return "Tax Compliance"
        case .gstSummary: return "GST Summary"

        case .execSummary: return "Executive Summary"
        case .profitAndLoss: return "Profit & Loss"
        case .balanceSheet: return "Balance Sheet"
        case .cashFlow: return "Cash Flow"
        case .arAging: return "AR Aging"
        case .gstReport: return "GST Report"
        case .expenseReport: return "Expense Report"
        case .paymentReport: return "Payment Report"
        case .invoiceReport: return "Invoice Report"
        case .mrrReport: return "MRR Report"

        case .users: return "Users"
        case .rolesPermissions: return "Roles & Permissions"
        case .settings: return "Settings"
        case .organizationProfile: return "Organization Profile"
        }
    }

    public var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2"

        case .invoices: return "doc.text.fill"
        case .orders: return "cart"
        case .estimates: return "doc.text"
        case .challans: return "truck.box"
        case .creditNotes: return "doc.badge.plus"

        case .purchaseOrders: return "doc.badge.gearshape"
        case .bills: return "doc.plaintext"
        case .debitNotes: return "doc.badge.arrow.up"
        case .vendors: return "storefront"

        case .products: return "shippingbox"
        case .inventory: return "building.columns"

        case .payments: return "creditcard"
        case .expenses: return "doc.plaintext"
        case .reconciliation: return "building.columns.fill"
        case .revenueRec: return "chart.line.uptrend.xyaxis"

        case .customers: return "person.2"
        case .companies: return "building.2"

        case .taxCompliance: return "tablecells"
        case .gstSummary: return "chart.pie"

        case .execSummary: return "chart.bar.doc.horizontal"
        case .profitAndLoss: return "chart.line.uptrend.xyaxis"
        case .balanceSheet: return "scales"
        case .cashFlow: return "arrow.triangle.2.circlepath"
        case .arAging: return "clock.arrow.circlepath"
        case .gstReport: return "doc.badge.gearshape"
        case .expenseReport: return "doc.plaintext.fill"
        case .paymentReport: return "creditcard.fill"
        case .invoiceReport: return "doc.text.fill"
        case .mrrReport: return "chart.xyaxis.line"

        case .users: return "person"
        case .rolesPermissions: return "lock"
        case .settings: return "gearshape"
        case .organizationProfile: return "building.2"
        }
    }

    public var badgeText: String? {
        switch self {
        case .invoices: return "24"
        default: return nil
        }
    }
}

public struct SidebarSectionModel: Identifiable {
    public let id: String
    public let title: String?
    public let items: [SidebarDestination]
}

public struct SidebarMockData {
    public static var sections: [SidebarSectionModel] {
        [
            SidebarSectionModel(id: "main", title: nil, items: [.dashboard]),
            SidebarSectionModel(id: "sales", title: "SALES", items: [.invoices, .orders, .estimates, .challans, .creditNotes]),
            SidebarSectionModel(id: "purchases", title: "PURCHASES", items: [.purchaseOrders, .bills, .debitNotes, .vendors]),
            SidebarSectionModel(id: "inventory", title: "INVENTORY", items: [.products, .inventory]),
            SidebarSectionModel(id: "finance", title: "FINANCE", items: [.payments, .expenses, .reconciliation, .revenueRec]),
            SidebarSectionModel(id: "customers", title: "CUSTOMERS", items: [.customers, .companies]),
            SidebarSectionModel(id: "tax", title: "GST & TAX", items: [.taxCompliance, .gstSummary]),
            SidebarSectionModel(id: "reports", title: "REPORTS", items: [.execSummary, .profitAndLoss, .balanceSheet, .cashFlow, .arAging, .gstReport, .expenseReport, .paymentReport, .invoiceReport, .mrrReport]),
            SidebarSectionModel(id: "administration", title: "ADMINISTRATION", items: [.users, .rolesPermissions, .settings, .organizationProfile])
        ]
    }
}

public struct SidebarView: View {
    @Binding var selectedItem: SidebarDestination?
    @Binding var searchText: String
    var isCollapsed: Bool
    var onToggleSidebar: (() -> Void)?

    public init(
        selectedItem: Binding<SidebarDestination?>,
        searchText: Binding<String> = .constant(""),
        isCollapsed: Bool = false,
        onToggleSidebar: (() -> Void)? = nil
    ) {
        self._selectedItem = selectedItem
        self._searchText = searchText
        self.isCollapsed = isCollapsed
        self.onToggleSidebar = onToggleSidebar
    }

    private var filteredSections: [SidebarSectionModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return SidebarMockData.sections
        }
        return SidebarMockData.sections.compactMap { section in
            let matchingItems = section.items.filter { $0.title.lowercased().contains(query) }
            guard !matchingItems.isEmpty else { return nil }
            return SidebarSectionModel(id: section.id, title: section.title, items: matchingItems)
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Scrollable Sidebar Navigation List
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: CommonSpacing.sidebarItemSpacing) {
                    ForEach(filteredSections) { section in
                        if let title = section.title {
                            if !isCollapsed {
                                HStack {
                                    Text(title.uppercased())
                                        .font(CommonFont.sidebarSectionHeader)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.top, CommonSpacing.sidebarSectionHeaderTopPadding)
                                .padding(.bottom, CommonSpacing.sidebarSectionHeaderBottomPadding)
                                .padding(.horizontal, 4)
                                .transition(.opacity)
                            } else {
                                Divider()
                                    .padding(.vertical, 8)
                                    .transition(.opacity)
                            }
                        }

                        ForEach(section.items, id: \.self) { item in
                            SidebarRowItem(
                                item: item,
                                isSelected: selectedItem == item,
                                isCollapsed: isCollapsed,
                                onSelect: {
                                    selectedItem = item
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, CommonSpacing.sidebarHorizontalPadding)
                .padding(.vertical, CommonSpacing.sidebarTopBottomPadding)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(isCollapsed ? "" : "ERP Pro")
        .toolbar(removing: .sidebarToggle)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onToggleSidebar?()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(CommonFont.sidebarToggleIcon)
                        .foregroundColor(.primary)
                }
            }
        }
    }
}

// MARK: - Native Sidebar Row Item
struct SidebarRowItem: View {
    let item: SidebarDestination
    let isSelected: Bool
    let isCollapsed: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                ZStack {
                    Image(systemName: item.iconName)
                        .font(CommonFont.sidebarIcon)
                        .foregroundColor(isSelected ? .white : .secondary)
                        .frame(width: 22, height: 22)
                }
                .frame(width: isCollapsed ? 44 : 22, height: 22)

                if !isCollapsed {
                    HStack(spacing: CommonSpacing.sidebarIconTextSpacing) {
                        Spacer().frame(width: 0)

                        Text(item.title)
                            .font(isSelected ? CommonFont.sidebarMenuItemSelected : CommonFont.sidebarMenuItem)
                            .foregroundColor(isSelected ? .white : .primary)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        if let badge = item.badgeText {
                            Text(badge)
                                .font(CommonFont.sidebarBadge)
                                .foregroundColor(isSelected ? Color.blue : .white)
                                .padding(.horizontal, 8)
                                .frame(height: CommonSpacing.badgeHeight)
                                .background(isSelected ? Color.white : Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, isCollapsed ? 4 : 10)
            .frame(height: CommonSpacing.sidebarRowHeight)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(CommonSpacing.sidebarSelectionCornerRadius)
        }
        .buttonStyle(.plain)
    }
}

