//
//  DashboardView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

public struct DashboardView: View {
    @StateObject private var controller = DashboardController()
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Home")
                    .font(CommonFont.title2)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HomeHeaderActionsView(isWideLayout: isWideLayout)
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

struct HomeHeaderActionsView: View {
    let isWideLayout: Bool
    @StateObject private var headerState = HomeHeaderState()

    var body: some View {
        HStack(spacing: CommonSpacing.xs) {
            // 1. Company Switcher Menu
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
                HStack(spacing: 4) {
                    Image(systemName: "building.2.fill")
                        .font(.caption)
                        .foregroundColor(CommonColor.primary)

                    if isWideLayout {
                        Text(headerState.selectedCompany)
                            .font(CommonFont.caption)
                            .bold()
                            .foregroundColor(CommonColor.primaryText)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(CommonColor.secondaryText)
                }
                .padding(.horizontal, CommonSpacing.xs + 2)
                .padding(.vertical, 5)
                .background(CommonColor.cardBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(CommonColor.primary.opacity(0.2), lineWidth: 1)
                )
            }

            // 2. User Profile Menu
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
                HStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(CommonColor.primary.gradient)
                            .frame(width: 24, height: 24)
                        Text(headerState.userInitials)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }

                    if isWideLayout {
                        Text(headerState.userName)
                            .font(CommonFont.caption)
                            .bold()
                            .foregroundColor(CommonColor.primaryText)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(CommonColor.secondaryText)
                }
                .padding(.horizontal, CommonSpacing.xs)
                .padding(.vertical, 3)
                .background(CommonColor.cardBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(CommonColor.primary.opacity(0.2), lineWidth: 1)
                )
            }
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

// MARK: - KPI Carousel / Grid Layout

struct KPIGridView: View {
    let kpis: DashboardKPIMetrics
    let isWideLayout: Bool

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md),
            GridItem(.flexible(), spacing: CommonSpacing.md)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
            HStack {
                Text(ConstantString.kpiOverview)
                    .font(CommonFont.title3)
                    .foregroundColor(CommonColor.primaryText)
                Spacer()
                if !isWideLayout {
                    Text("Swipe")
                        .font(CommonFont.caption2)
                        .foregroundColor(CommonColor.secondaryText)
                }
            }
            .padding(.horizontal, CommonSpacing.xs)

            if isWideLayout {
                LazyVGrid(columns: columns, spacing: CommonSpacing.md) {
                    allKPICards
                }
            } else {
                TabView {
                    // Page 0: Sales & Revenue
                    HStack(spacing: CommonSpacing.sm) {
                        if let sales = kpis.totalSales {
                            DashboardKPICard(
                                title: ConstantString.totalSales,
                                value: CommonCurrencyFormatter.format(sales.amount),
                                trendPercentage: sales.trendPercentage,
                                trendComparison: sales.trendComparison,
                                sparklineData: sales.sparkline,
                                iconName: "dollarsign.circle.fill",
                                iconColor: CommonColor.primary
                            )
                        }
                        if let revenue = kpis.revenueOverview {
                            DashboardKPICard(
                                title: ConstantString.revenueOverview,
                                value: CommonCurrencyFormatter.format(revenue.amount),
                                subtitle: revenue.monthlyTrend,
                                trendComparison: revenue.comparison,
                                iconName: "chart.line.uptrend.xyaxis.circle.fill",
                                iconColor: CommonColor.success
                            )
                        }
                    }
                    .padding(.horizontal, 2)

                    // Page 1: Payments & Orders
                    HStack(spacing: CommonSpacing.sm) {
                        if let pending = kpis.pendingPayments {
                            DashboardKPICard(
                                title: ConstantString.pendingPayments,
                                value: CommonCurrencyFormatter.format(pending.amount),
                                subtitle: "\(pending.unpaidInvoiceCount) \(ConstantString.unpaidInvoices)",
                                iconName: "clock.fill",
                                iconColor: CommonColor.warning
                            )
                        }
                        if let orders = kpis.ordersSummary {
                            DashboardKPICard(
                                title: ConstantString.ordersSummary,
                                value: "\(orders.totalOrders)",
                                subtitle: "\(orders.pendingApprovalCount) \(ConstantString.pendingApprovalOrders)",
                                iconName: "cart.fill",
                                iconColor: CommonColor.info
                            )
                        }
                    }
                    .padding(.horizontal, 2)

                    // Page 2: Inventory & Customers
                    HStack(spacing: CommonSpacing.sm) {
                        if let inventory = kpis.inventorySummary {
                            DashboardKPICard(
                                title: ConstantString.inventorySummary,
                                value: "\(inventory.totalItemsInStock)",
                                subtitle: ConstantString.totalInStock,
                                iconName: "shippingbox.fill",
                                iconColor: CommonColor.accent
                            )
                        }
                        if let customers = kpis.customerActivity {
                            DashboardKPICard(
                                title: ConstantString.customerActivity,
                                value: "\(customers.activeCustomerCount)",
                                subtitle: "\(customers.newCustomerCount) \(ConstantString.newCustomers)",
                                iconName: "person.2.fill",
                                iconColor: CommonColor.primary
                            )
                        }
                    }
                    .padding(.horizontal, 2)

                    // Page 3: Alerts & Overview
                    HStack(spacing: CommonSpacing.sm) {
                        if let lowStock = kpis.lowStockAlerts {
                            DashboardKPICard(
                                title: ConstantString.lowStockAlerts,
                                value: "\(lowStock.itemsBelowReorderCount)",
                                subtitle: ConstantString.itemsBelowReorder,
                                iconName: "exclamationmark.triangle.fill",
                                iconColor: CommonColor.danger
                            )
                        }
                        if let overview = kpis.businessOverview {
                            BusinessOverviewKPICard(metric: overview)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 155)
            }
        }
    }

    @ViewBuilder
    private var allKPICards: some View {
        if let sales = kpis.totalSales {
            DashboardKPICard(
                title: ConstantString.totalSales,
                value: CommonCurrencyFormatter.format(sales.amount),
                trendPercentage: sales.trendPercentage,
                trendComparison: sales.trendComparison,
                sparklineData: sales.sparkline,
                iconName: "dollarsign.circle.fill",
                iconColor: CommonColor.primary
            )
        }
        if let revenue = kpis.revenueOverview {
            DashboardKPICard(
                title: ConstantString.revenueOverview,
                value: CommonCurrencyFormatter.format(revenue.amount),
                subtitle: revenue.monthlyTrend,
                trendComparison: revenue.comparison,
                iconName: "chart.line.uptrend.xyaxis.circle.fill",
                iconColor: CommonColor.success
            )
        }
        if let pending = kpis.pendingPayments {
            DashboardKPICard(
                title: ConstantString.pendingPayments,
                value: CommonCurrencyFormatter.format(pending.amount),
                subtitle: "\(pending.unpaidInvoiceCount) \(ConstantString.unpaidInvoices)",
                iconName: "clock.fill",
                iconColor: CommonColor.warning
            )
        }
        if let orders = kpis.ordersSummary {
            DashboardKPICard(
                title: ConstantString.ordersSummary,
                value: "\(orders.totalOrders)",
                subtitle: "\(orders.pendingApprovalCount) \(ConstantString.pendingApprovalOrders)",
                iconName: "cart.fill",
                iconColor: CommonColor.info
            )
        }
        if let inventory = kpis.inventorySummary {
            DashboardKPICard(
                title: ConstantString.inventorySummary,
                value: "\(inventory.totalItemsInStock)",
                subtitle: ConstantString.totalInStock,
                iconName: "shippingbox.fill",
                iconColor: CommonColor.accent
            )
        }
        if let customers = kpis.customerActivity {
            DashboardKPICard(
                title: ConstantString.customerActivity,
                value: "\(customers.activeCustomerCount)",
                subtitle: "\(customers.newCustomerCount) \(ConstantString.newCustomers)",
                iconName: "person.2.fill",
                iconColor: CommonColor.primary
            )
        }
        if let lowStock = kpis.lowStockAlerts {
            DashboardKPICard(
                title: ConstantString.lowStockAlerts,
                value: "\(lowStock.itemsBelowReorderCount)",
                subtitle: ConstantString.itemsBelowReorder,
                iconName: "exclamationmark.triangle.fill",
                iconColor: CommonColor.danger
            )
        }
        if let overview = kpis.businessOverview {
            BusinessOverviewKPICard(metric: overview)
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
