//
//  DashboardChartSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Charts
import Combine

public final class DashboardChartViewState: ObservableObject {
    @Published public var salesMode: DashboardChartSection.SalesChartMode = .monthlySales
    @Published public var paymentMode: DashboardChartSection.PaymentChartMode = .collection
    @Published public var inventoryMode: DashboardChartSection.InventoryChartMode = .stockTrend
    public init() {}
}

public struct DashboardChartSection: View {
    let chartsData: DashboardChartsData
    @StateObject private var chartState = DashboardChartViewState()

    public init(chartsData: DashboardChartsData) {
        self.chartsData = chartsData
    }

    public enum SalesChartMode: String, CaseIterable, Identifiable {
        case monthlySales = "Monthly Sales"
        case revenueTrend = "Revenue Trend"
        public var id: String { rawValue }
    }

    public enum PaymentChartMode: String, CaseIterable, Identifiable {
        case collection = "Payment Collection"
        case arAging = "AR Aging Breakdown"
        public var id: String { rawValue }
    }

    public enum InventoryChartMode: String, CaseIterable, Identifiable {
        case stockTrend = "Stock Trend"
        case dealerActivity = "Dealer Activity"
        case cashFlow = "Cash Flow Forecast"
        public var id: String { rawValue }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
            HStack {
                Text("Analytics & Charts")
                    .font(CommonFont.title3)
                    .foregroundColor(CommonColor.primaryText)
                Spacer()
                Text("Swipe / Long-press for options")
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.secondaryText)
            }
            .padding(.horizontal, CommonSpacing.xs)

            TabView {
                // Card 1: Sales Analytics
                SalesChartCard(chartsData: chartsData, mode: $chartState.salesMode)
                    .padding(.horizontal, 2)

                // Card 2: Payment & AR Aging Analytics
                PaymentChartCard(chartsData: chartsData, mode: $chartState.paymentMode)
                    .padding(.horizontal, 2)

                // Card 3: Inventory & Cash Flow Analytics
                InventoryChartCard(chartsData: chartsData, mode: $chartState.inventoryMode)
                    .padding(.horizontal, 2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 290)
        }
    }
}

// MARK: - Card 1: Sales Analytics Card

struct SalesChartCard: View {
    let chartsData: DashboardChartsData
    @Binding var mode: DashboardChartSection.SalesChartMode

    var body: some View {
        ChartCardContainer(
            title: mode.rawValue,
            subtitle: "Sales & Revenue",
            menuContent: {
                ForEach(DashboardChartSection.SalesChartMode.allCases) { item in
                    Button {
                        mode = item
                    } label: {
                        HStack {
                            Text(item.rawValue)
                            if mode == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        ) {
            switch mode {
            case .monthlySales:
                if let monthlySales = chartsData.monthlySales, !monthlySales.isEmpty {
                    Chart(monthlySales) { item in
                        BarMark(
                            x: .value("Month", item.month),
                            y: .value("Sales", item.salesValue)
                        )
                        .foregroundStyle(CommonColor.chartPrimary.gradient)
                        .cornerRadius(4)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            case .revenueTrend:
                if let revenueTrend = chartsData.revenueTrend, !revenueTrend.isEmpty {
                    Chart {
                        ForEach(revenueTrend) { item in
                            LineMark(
                                x: .value("Period", item.label),
                                y: .value("Amount", item.thisYear),
                                series: .value("Year", ConstantString.thisYear)
                            )
                            .foregroundStyle(CommonColor.chartPrimary)

                            LineMark(
                                x: .value("Period", item.label),
                                y: .value("Amount", item.lastYear),
                                series: .value("Year", ConstantString.lastYear)
                            )
                            .foregroundStyle(CommonColor.chartSecondary)
                        }
                    }
                    .chartLegend(position: .top, alignment: .trailing)
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            }
        }
    }
}

// MARK: - Card 2: Payment & AR Aging Analytics Card

struct PaymentChartCard: View {
    let chartsData: DashboardChartsData
    @Binding var mode: DashboardChartSection.PaymentChartMode

    var body: some View {
        ChartCardContainer(
            title: mode.rawValue,
            subtitle: "Payment Health & Collections",
            menuContent: {
                ForEach(DashboardChartSection.PaymentChartMode.allCases) { item in
                    Button {
                        mode = item
                    } label: {
                        HStack {
                            Text(item.rawValue)
                            if mode == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        ) {
            switch mode {
            case .collection:
                if let collection = chartsData.paymentCollection {
                    VStack(spacing: CommonSpacing.md) {
                        PaymentCollectionGaugeView(collection: collection)
                    }
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            case .arAging:
                if let arAging = chartsData.arAging, !arAging.isEmpty {
                    Chart(arAging) { item in
                        BarMark(
                            x: .value("Period", item.period),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(by: .value("Period", item.period))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            }
        }
    }
}

// MARK: - Card 3: Inventory & Cash Flow Card

struct InventoryChartCard: View {
    let chartsData: DashboardChartsData
    @Binding var mode: DashboardChartSection.InventoryChartMode

    var body: some View {
        ChartCardContainer(
            title: mode.rawValue,
            subtitle: "Stock & Cash Operations",
            menuContent: {
                ForEach(DashboardChartSection.InventoryChartMode.allCases) { item in
                    Button {
                        mode = item
                    } label: {
                        HStack {
                            Text(item.rawValue)
                            if mode == item {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        ) {
            switch mode {
            case .stockTrend:
                if let inventoryTrend = chartsData.inventoryTrend, !inventoryTrend.isEmpty {
                    Chart(inventoryTrend) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Stock", item.stockLevel)
                        )
                        .foregroundStyle(CommonColor.chartQuaternary.gradient)

                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Stock", item.stockLevel)
                        )
                        .foregroundStyle(CommonColor.chartQuaternary.opacity(0.1))
                    }
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            case .dealerActivity:
                if let dealerActivity = chartsData.dealerActivity, !dealerActivity.isEmpty {
                    Chart(dealerActivity) { item in
                        BarMark(
                            x: .value("Dealer", item.dealerName),
                            y: .value("Value", item.orderValue)
                        )
                        .foregroundStyle(CommonColor.chartTertiary.gradient)
                    }
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            case .cashFlow:
                if let cashFlow = chartsData.cashFlowForecast, !cashFlow.isEmpty {
                    Chart {
                        ForEach(cashFlow) { item in
                            BarMark(
                                x: .value("Date", item.date),
                                y: .value("Inflows", item.inflows)
                            )
                            .foregroundStyle(CommonColor.success)

                            BarMark(
                                x: .value("Date", item.date),
                                y: .value("Outflows", -item.outflows)
                            )
                            .foregroundStyle(CommonColor.danger)

                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Net", item.netCashFlow)
                            )
                            .foregroundStyle(CommonColor.primary)
                        }
                    }
                    .frame(height: 180)
                } else {
                    EmptyChartView()
                }
            }
        }
    }
}

// MARK: - Reusable Chart Card Shell with Context Menu

struct ChartCardContainer<MenuContent: View, Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let menuContent: () -> MenuContent
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CommonFont.subheadline)
                        .bold()
                        .foregroundColor(CommonColor.primaryText)
                    Text(subtitle)
                        .font(CommonFont.caption2)
                        .foregroundColor(CommonColor.secondaryText)
                }

                Spacer()

                Menu {
                    menuContent()
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundColor(CommonColor.primary)
                        .padding(CommonSpacing.xs)
                }
            }

            content()
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .contextMenu {
            menuContent()
        }
    }
}

struct EmptyChartView: View {
    var body: some View {
        VStack {
            Text(ConstantString.emptyMessage)
                .font(CommonFont.caption)
                .foregroundColor(CommonColor.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Payment Collection Gauge / Visualizer

struct PaymentCollectionGaugeView: View {
    let collection: PaymentCollectionDataPoint

    var body: some View {
        VStack(spacing: CommonSpacing.md) {
            HStack(spacing: CommonSpacing.sm) {
                CollectionStatCard(
                    title: ConstantString.collected,
                    amount: collection.collected,
                    color: CommonColor.success
                )
                CollectionStatCard(
                    title: ConstantString.pending,
                    amount: collection.pending,
                    color: CommonColor.warning
                )
                CollectionStatCard(
                    title: ConstantString.overdue,
                    amount: collection.overdue,
                    color: CommonColor.danger
                )
            }
        }
    }
}

struct CollectionStatCard: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
            }
            Text(CommonCurrencyFormatter.format(amount))
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(CommonColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(CommonSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusSm))
    }
}
