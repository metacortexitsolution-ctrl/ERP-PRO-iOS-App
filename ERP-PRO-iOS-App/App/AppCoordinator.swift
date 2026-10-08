//
//  AppCoordinator.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case dashboard
    case invoice
    case payment
    case more
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: return ConstantString.dashboard
        case .invoice: return ConstantString.invoice
        case .payment: return ConstantString.payment
        case .more: return ConstantString.more
        case .settings: return ConstantString.settings
        }
    }

    public var iconName: String {
        switch self {
        case .dashboard: return "house.fill"
        case .invoice: return "doc.text.fill"
        case .payment: return "creditcard.fill"
        case .more: return "ellipsis.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

public final class AppCoordinatorState: ObservableObject {
    @Published public var selectedTab: AppTab = .dashboard
    public init() {}
}

public struct AppCoordinatorView: View {
    @StateObject private var coordinatorState = AppCoordinatorState()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init() {}

    public var body: some View {
        if DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular {
            NavigationSplitView {
                List(selection: Binding(
                    get: { coordinatorState.selectedTab },
                    set: { newTab in if let newTab = newTab { coordinatorState.selectedTab = newTab } }
                )) {
                    ForEach(AppTab.allCases) { tab in
                        NavigationLink(value: tab) {
                            Label(tab.title, systemImage: tab.iconName)
                        }
                    }
                }
                .navigationTitle("ERP Pro")
            } detail: {
                tabContentView(for: coordinatorState.selectedTab)
            }
        } else {
            TabView(selection: $coordinatorState.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack {
                        tabContentView(for: tab)
                            .navigationDestination(for: SidebarDestination.self) { destination in
                                AppCoordinatorView.destinationView(for: destination)
                            }
                    }
                    .tabItem {
                        Label(tab.title, systemImage: tab.iconName)
                    }
                    .tag(tab)
                }
            }
            .accentColor(.blue)
        }
    }

    @ViewBuilder
    private func tabContentView(for tab: AppTab) -> some View {
        switch tab {
        case .dashboard:
            DashboardView()
        case .invoice:
            TabPlaceholderView(title: ConstantString.invoice, description: ConstantString.invoiceModulePlaceholder)
        case .payment:
            TabPlaceholderView(title: ConstantString.payment, description: ConstantString.paymentModulePlaceholder)
        case .more:
            MoreView()
        case .settings:
            TabPlaceholderView(title: ConstantString.settings, description: ConstantString.settingsModulePlaceholder)
        }
    }
    @ViewBuilder
    public static func destinationView(for destination: SidebarDestination?) -> some View {
        switch destination {
        case .dashboard, .none:
            DashboardView()
        case .some(let dest):
            switch dest {
            case .invoices:
                SalesDocumentListView(documentType: .invoice)
            case .orders:
                SalesDocumentListView(documentType: .salesOrder)
            case .estimates:
                SalesDocumentListView(documentType: .estimate)
            case .challans:
                SalesDocumentListView(documentType: .deliveryChallan)
            case .creditNotes:
                SalesDocumentListView(documentType: .creditNote)
            default:
                TabPlaceholderView(title: dest.title, description: "\(dest.title) module & management")
            }
        }
    }

    @ViewBuilder
    private func sidebarContentView(for destination: SidebarDestination?) -> some View {
        AppCoordinatorView.destinationView(for: destination)
    }
}

// MARK: - Tab Placeholders (Internal to Navigation Shell)

struct TabPlaceholderView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            Image(systemName: "square.dashed")
                .font(.system(size: 48))
                .foregroundColor(CommonColor.secondaryText)
            Text(title)
                .font(CommonFont.title2)
            Text(description)
                .font(CommonFont.body)
                .foregroundColor(CommonColor.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle(title)
    }
}

struct MorePlaceholderView: View {
    let modules: [String] = [
        "Customers", "Vendors", "Products", "Orders",
        "Estimates", "Delivery Challans", "Credit Notes", "Purchase Orders",
        "Bills", "Debit Notes", "Expenses", "Inventory",
        "Bank Reconciliation", "Revenue Recognition", "Tax Compliance", "Reports",
        "Administration", "Companies", "Workflow Automation", "Customer Portal"
    ]

    var body: some View {
        List {
            Section(header: Text(ConstantString.moreModulesTitle)) {
                ForEach(modules, id: \.self) { module in
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(CommonColor.primary)
                        Text(module)
                            .font(CommonFont.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(CommonColor.secondaryText)
                    }
                }
            }
        }
        .navigationTitle(ConstantString.more)
    }
}
