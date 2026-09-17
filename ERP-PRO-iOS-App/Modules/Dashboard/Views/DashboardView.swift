//
//  DashboardView.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardView: View {
    @StateObject private var controller = DashboardController()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
        .navigationTitle(ConstantString.dashboard)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await controller.fetchDashboardData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .task {
            await controller.fetchDashboardData()
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
            VStack(alignment: .leading, spacing: CommonSpacing.lg) {
                // 1. Alert Banners
                if let alerts = data.alertBanners, !alerts.isEmpty {
                    DashboardAlertSection(alerts: alerts)
                }

                // 2. KPI Cards Grid
                if let kpis = data.kpis {
                    KPIGridView(kpis: kpis, isWideLayout: isWideLayout)
                }

                // 3. Charts Section
                if let charts = data.charts {
                    DashboardChartSection(chartsData: charts)
                }

                // 4. Operations & Lists Section
                DashboardListSection(
                    pipeline: data.ordersPipeline,
                    topCustomers: data.topCustomers,
                    pendingApprovals: data.pendingApprovals,
                    dealerPerformance: data.dealerPerformance,
                    supportTicketSummary: data.supportTicketSummary,
                    lowStockItems: data.lowStockItems
                )

                // 5. Recent Activity Section
                if let activities = data.recentActivities, !activities.isEmpty {
                    DashboardActivitySection(activities: activities)
                }
            }
            .padding(CommonSpacing.lg)
        }
        .background(CommonColor.background)
        .refreshable {
            await controller.fetchDashboardData()
        }
    }
}

// MARK: - KPI Grid Layout

struct KPIGridView: View {
    let kpis: DashboardKPIMetrics
    let isWideLayout: Bool

    private var columns: [GridItem] {
        if isWideLayout {
            return [
                GridItem(.flexible(), spacing: CommonSpacing.md),
                GridItem(.flexible(), spacing: CommonSpacing.md),
                GridItem(.flexible(), spacing: CommonSpacing.md),
                GridItem(.flexible(), spacing: CommonSpacing.md)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: CommonSpacing.md),
                GridItem(.flexible(), spacing: CommonSpacing.md)
            ]
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.kpiOverview)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            LazyVGrid(columns: columns, spacing: CommonSpacing.md) {
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
