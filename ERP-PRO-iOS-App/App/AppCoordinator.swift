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
    @Published public var selectedSidebarDestination: SidebarDestination? = .dashboard
    @Published public var isSidebarCollapsed: Bool = false
    @Published public var sidebarSearchText: String = ""

    public init() {}

    public func toggleSidebar() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            isSidebarCollapsed.toggle()
        }
    }
}

public struct AppCoordinatorView: View {
    @StateObject private var coordinatorState = AppCoordinatorState()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init() {}

    public var body: some View {
        if DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular {
            NavigationSplitView {
                SidebarView(
                    selectedItem: $coordinatorState.selectedSidebarDestination,
                    searchText: $coordinatorState.sidebarSearchText,
                    isCollapsed: coordinatorState.isSidebarCollapsed,
                    onToggleSidebar: {
                        coordinatorState.toggleSidebar()
                    }
                )
                .navigationSplitViewColumnWidth(
                    min: coordinatorState.isSidebarCollapsed ? 70 : 280,
                    ideal: coordinatorState.isSidebarCollapsed ? 80 : 310,
                    max: coordinatorState.isSidebarCollapsed ? 90 : 350
                )
            } detail: {
                sidebarContentView(for: coordinatorState.selectedSidebarDestination)
            }
            .toolbar(removing: .sidebarToggle)
        } else {
            TabView(selection: $coordinatorState.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    NavigationStack {
                        tabContentView(for: tab)
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
            InvoiceListView()
        case .payment:
            TabPlaceholderView(title: ConstantString.payment, description: ConstantString.paymentModulePlaceholder)
        case .more:
            MoreView()
        case .settings:
            TabPlaceholderView(title: ConstantString.settings, description: ConstantString.settingsModulePlaceholder)
        }
    }

    @ViewBuilder
    private func sidebarContentView(for destination: SidebarDestination?) -> some View {
        switch destination {
        case .dashboard, .none:
            DashboardView()
        case .some(let dest):
            switch dest {
            case .invoices:
                InvoiceListView()
            default:
                TabPlaceholderView(title: dest.title, description: "\(dest.title) module & management")
            }
        }
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
