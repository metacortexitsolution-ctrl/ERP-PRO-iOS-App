//
//  DashboardView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public struct DashboardView: View {
    @StateObject private var controller = DashboardController()
    @StateObject private var headerState = HomeHeaderState()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isWideLayout: Bool {
        DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular
    }

    public init() {}

    public var body: some View {
        Group {
            switch controller.state {
            case .loading:
                LoadingDashboardStateView()
            case .loaded(let data):
                LoadedDashboardStateView(data: data, controller: controller)
            case .empty:
                EmptyDashboardStateView(controller: controller)
            case .error(let errorMessage):
                ErrorDashboardStateView(errorMessage: errorMessage, controller: controller)
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CompanyHeaderMenuView(headerState: headerState)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                ProfileHeaderMenuView(headerState: headerState)
            }
        }
        .task {
            await controller.fetchDashboardData()
        }
    }
}

// MARK: - Header Actions (Company & Profile Menus)

public final class HomeHeaderState: ObservableObject {
    @Published public var selectedCompany: String = "Acme ERP Enterprises"
    @Published public var companies: [String] = [
        "Acme ERP Enterprises",
        "Global Trade Pvt Ltd",
        "Apex Logistics Solutions"
    ]
    @Published public var userName: String = "Dhairya Patel"
    @Published public var userInitials: String = "DP"
    public init() {}
}

struct CompanyHeaderMenuView: View {
    @ObservedObject var headerState: HomeHeaderState

    var body: some View {
        Menu {
            Section(header: Text("Companies")) {
                ForEach(headerState.companies, id: \.self) { company in
                    Button {
                        headerState.selectedCompany = company
                    } label: {
                        HStack {
                            Text(company)
                            if headerState.selectedCompany == company {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            Divider()
            Button {
                // Switch company action
            } label: {
                Label(ConstantString.switchCompany, systemImage: "arrow.triangle.2.circlepath")
            }
        } label: {
            ZStack {
                Circle()
                    .fill(CommonColor.cardBackground)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

                Circle()
                    .stroke(CommonColor.primary.opacity(0.18), lineWidth: 1)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CommonColor.primary)
            }
            .frame(width: 34, height: 34)
        }
    }
}

struct ProfileHeaderMenuView: View {
    @ObservedObject var headerState: HomeHeaderState

    var body: some View {
        Menu {
            Section(header: Text(headerState.userName)) {
                Button {
                    // My Profile
                } label: {
                    Label(ConstantString.myProfile, systemImage: "person.circle")
                }
                Button {
                    // Notification Preferences
                } label: {
                    Label(ConstantString.notificationPreferences, systemImage: "bell")
                }
                Button {
                    // Theme
                } label: {
                    Label(ConstantString.theme, systemImage: "circle.line.vertical")
                }
                Button {
                    // System Settings
                } label: {
                    Label(ConstantString.systemSettings, systemImage: "gearshape")
                }
            }
            Divider()
            Button(role: .destructive) {
                // Log out
            } label: {
                Label(ConstantString.logOut, systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            ZStack {
                Circle()
                    .fill(CommonColor.cardBackground)
                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

                Circle()
                    .stroke(CommonColor.primary.opacity(0.18), lineWidth: 1)

                Image(systemName: "person.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(CommonColor.primary)
            }
            .frame(width: 34, height: 34)
        }
    }
}

// MARK: - Loaded Content View

struct LoadedDashboardStateView: View {
    let data: DashboardData
    @ObservedObject var controller: DashboardController
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isWideLayout: Bool {
        DeviceInfo.isPad || DeviceInfo.isMacCatalyst || horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CommonSpacing.md) {
                // 1. Alert Banners (Compact Paging Carousel)
                if let alerts = data.alertBanners, !alerts.isEmpty {
                    DashboardAlertSection(alerts: alerts)
                }

                // 2. KPI Cards (Paging Carousel on iPhone, Multi-Column Grid on iPad/Mac)
                if let kpis = data.kpis {
                    KPIGridView(kpis: kpis, isWideLayout: isWideLayout)
                }

                // 3. Analytics & Charts Carousel (Swipeable cards with ContextMenu)
                if let charts = data.charts {
                    DashboardChartSection(chartsData: charts)
                }

                // 4. Operations & Lists Section (Compact Horizontal Scroll Views & Tables)
                DashboardListSection(
                    pipeline: data.ordersPipeline,
                    topCustomers: data.topCustomers,
                    pendingApprovals: data.pendingApprovals,
                    dealerPerformance: data.dealerPerformance,
                    supportTicketSummary: data.supportTicketSummary,
                    lowStockItems: data.lowStockItems
                )

                // 5. Recent Activity Section (Compact Horizontal Scroll View)
                if let activities = data.recentActivities, !activities.isEmpty {
                    DashboardActivitySection(activities: activities)
                }
            }
            .padding(CommonSpacing.md)
        }
        .background(CommonColor.background)
        .refreshable {
            await controller.fetchDashboardData()
        }
    }
}

// MARK: - Width Measurement & State Helpers

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public final class KPIGridState: ObservableObject {
    @Published public var containerWidth: CGFloat = 0
    public init() {}
}

public final class KPI2x2PagingState: ObservableObject {
    @Published public var currentPage: Int = 0
    public init() {}
}

// MARK: - KPI Grid Layout

struct KPIGridView: View {
    let kpis: DashboardKPIMetrics
    let isWideLayout: Bool
    @StateObject private var gridState = KPIGridState()

    private var use4ColumnGrid: Bool {
        if gridState.containerWidth > 0 {
            return gridState.containerWidth >= 640
        }
        return isWideLayout
    }

    private var wideColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md)
        ]
    }

    var body: some View {
        Group {
            if use4ColumnGrid {
                LazyVGrid(columns: wideColumns, spacing: CommonSpacing.md) {
                    ForEach(0..<kpiCardViews.count, id: \.self) { index in
                        kpiCardViews[index]
                    }
                }
                .frame(maxWidth: 1300)
            } else {
                KPI2x2PagingView(cards: kpiCardViews)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: WidthPreferenceKey.self, value: geo.size.width)
            }
        )
        .onPreferenceChange(WidthPreferenceKey.self) { width in
            if width > 0 && width != gridState.containerWidth {
                gridState.containerWidth = width
            }
        }
    }

    private var kpiCardViews: [AnyView] {
        var views: [AnyView] = []
        if let sales = kpis.totalSales {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.totalSales,
                    value: CommonCurrencyFormatter.format(sales.amount),
                    trendPercentage: sales.trendPercentage,
                    trendComparison: sales.trendComparison,
                    sparklineData: sales.sparkline,
                    iconName: "dollarsign.circle.fill",
                    iconColor: CommonColor.primary
                )
            ))
        }
        if let revenue = kpis.revenueOverview {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.revenueOverview,
                    value: CommonCurrencyFormatter.format(revenue.amount),
                    subtitle: revenue.monthlyTrend,
                    trendComparison: revenue.comparison,
                    iconName: "chart.line.uptrend.xyaxis.circle.fill",
                    iconColor: CommonColor.success
                )
            ))
        }
        if let pending = kpis.pendingPayments {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.pendingPayments,
                    value: CommonCurrencyFormatter.format(pending.amount),
                    subtitle: "\(pending.unpaidInvoiceCount) \(ConstantString.unpaidInvoices)",
                    iconName: "clock.fill",
                    iconColor: CommonColor.warning
                )
            ))
        }
        if let orders = kpis.ordersSummary {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.ordersSummary,
                    value: "\(orders.totalOrders)",
                    subtitle: "\(orders.pendingApprovalCount) \(ConstantString.pendingApprovalOrders)",
                    iconName: "cart.fill",
                    iconColor: CommonColor.info
                )
            ))
        }
        if let inventory = kpis.inventorySummary {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.inventorySummary,
                    value: "\(inventory.totalItemsInStock)",
                    subtitle: ConstantString.totalInStock,
                    iconName: "shippingbox.fill",
                    iconColor: CommonColor.accent
                )
            ))
        }
        if let customers = kpis.customerActivity {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.customerActivity,
                    value: "\(customers.activeCustomerCount)",
                    subtitle: "\(customers.newCustomerCount) \(ConstantString.newCustomers)",
                    iconName: "person.2.fill",
                    iconColor: CommonColor.primary
                )
            ))
        }
        if let lowStock = kpis.lowStockAlerts {
            views.append(AnyView(
                DashboardKPICard(
                    title: ConstantString.lowStockAlerts,
                    value: "\(lowStock.itemsBelowReorderCount)",
                    subtitle: ConstantString.itemsBelowReorder,
                    iconName: "exclamationmark.triangle.fill",
                    iconColor: CommonColor.danger
                )
            ))
        }
        if let overview = kpis.businessOverview {
            views.append(AnyView(BusinessOverviewKPICard(metric: overview)))
        }
        return views
    }
}

// MARK: - Responsive 2x2 Paging Fallback View

struct KPI2x2PagingView: View {
    let cards: [AnyView]
    @StateObject private var pagingState = KPI2x2PagingState()

    private var page1Cards: [AnyView] {
        Array(cards.prefix(4))
    }

    private var page2Cards: [AnyView] {
        Array(cards.dropFirst(4).prefix(4))
    }

    private let columns = [
        GridItem(.flexible(), spacing: CommonSpacing.sm),
        GridItem(.flexible(), spacing: CommonSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: CommonSpacing.sm) {
            TabView(selection: $pagingState.currentPage) {
                LazyVGrid(columns: columns, spacing: CommonSpacing.sm) {
                    ForEach(0..<page1Cards.count, id: \.self) { index in
                        page1Cards[index]
                    }
                }
                .tag(0)

                LazyVGrid(columns: columns, spacing: CommonSpacing.sm) {
                    ForEach(0..<page2Cards.count, id: \.self) { index in
                        page2Cards[index]
                    }
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 256)

            // Page Indicator Dots
            HStack(spacing: 6) {
                Circle()
                    .fill(pagingState.currentPage == 0 ? CommonColor.primary : CommonColor.secondaryText.opacity(0.3))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(pagingState.currentPage == 1 ? CommonColor.primary : CommonColor.secondaryText.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}



// MARK: - State Views

struct LoadingDashboardStateView: View {
    var body: some View {
        VStack(spacing: CommonSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text(ConstantString.loadingDashboard)
                .font(CommonFont.subheadline)
                .foregroundColor(CommonColor.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}

struct EmptyDashboardStateView: View {
    @ObservedObject var controller: DashboardController

    var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(CommonColor.secondaryText)

            Text(ConstantString.emptyTitle)
                .font(CommonFont.title2)
                .foregroundColor(CommonColor.primaryText)

            Text(ConstantString.emptyMessage)
                .font(CommonFont.body)
                .foregroundColor(CommonColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await controller.fetchDashboardData()
                }
            } label: {
                Label(ConstantString.refresh, systemImage: "arrow.clockwise")
                    .font(CommonFont.subheadline)
                    .bold()
                    .padding(.horizontal, CommonSpacing.lg)
                    .padding(.vertical, CommonSpacing.sm)
                    .foregroundColor(.white)
                    .background(CommonColor.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}

struct ErrorDashboardStateView: View {
    let errorMessage: String
    @ObservedObject var controller: DashboardController

    var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(CommonColor.danger)

            Text(ConstantString.errorTitle)
                .font(CommonFont.title2)
                .foregroundColor(CommonColor.primaryText)

            Text(errorMessage)
                .font(CommonFont.body)
                .foregroundColor(CommonColor.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await controller.fetchDashboardData()
                }
            } label: {
                Label(ConstantString.retry, systemImage: "arrow.clockwise")
                    .font(CommonFont.subheadline)
                    .bold()
                    .padding(.horizontal, CommonSpacing.lg)
                    .padding(.vertical, CommonSpacing.sm)
                    .foregroundColor(.white)
                    .background(CommonColor.primary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CommonColor.background)
    }
}
