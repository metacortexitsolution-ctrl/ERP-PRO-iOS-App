//
//  DashboardChartSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Charts

public struct DashboardChartSection: View {
    let chartsData: DashboardChartsData

    public init(chartsData: DashboardChartsData) {
        self.chartsData = chartsData
    }

    public var body: some View {
        VStack(spacing: CommonSpacing.lg) {
            // 1. Monthly Sales Chart
            if let monthlySales = chartsData.monthlySales, !monthlySales.isEmpty {
                ChartContainerView(title: ConstantString.monthlySalesChart) {
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
                    .frame(height: 200)
                }
            }

            // 2. Revenue Trend (This Year vs Last Year)
            if let revenueTrend = chartsData.revenueTrend, !revenueTrend.isEmpty {
                ChartContainerView(title: ConstantString.revenueTrend) {
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
                    .frame(height: 200)
                }
            }

            // 3. Payment Collection Gauge / Breakdown
            if let collection = chartsData.paymentCollection {
                ChartContainerView(title: ConstantString.paymentCollection) {
                    VStack(spacing: CommonSpacing.md) {
                        PaymentCollectionGaugeView(collection: collection)
                    }
                }
            }

            // 4. Inventory Trend (30-day stock progression)
            if let inventoryTrend = chartsData.inventoryTrend, !inventoryTrend.isEmpty {
                ChartContainerView(title: ConstantString.inventoryTrend) {
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
                }
            }

            // 5. Dealer Activity (Order volume & value)
            if let dealerActivity = chartsData.dealerActivity, !dealerActivity.isEmpty {
                ChartContainerView(title: ConstantString.dealerActivity) {
                    Chart(dealerActivity) { item in
                        BarMark(
                            x: .value("Dealer", item.dealerName),
                            y: .value("Value", item.orderValue)
                        )
                        .foregroundStyle(CommonColor.chartTertiary.gradient)
                    }
                    .frame(height: 200)
                }
            }

            // 6. AR Aging (Current, 1-30, 31-60, 61-90, 90+ days)
            if let arAging = chartsData.arAging, !arAging.isEmpty {
                ChartContainerView(title: ConstantString.arAging) {
                    Chart(arAging) { item in
                        BarMark(
                            x: .value("Period", item.period),
                            y: .value("Amount", item.amount)
                        )
                        .foregroundStyle(by: .value("Period", item.period))
                    }
                    .chartLegend(.hidden)
                    .frame(height: 200)
                }
            }

            // 7. Cash Flow Forecast (Inflows, Outflows, Net Cash Flow)
            if let cashFlow = chartsData.cashFlowForecast, !cashFlow.isEmpty {
                ChartContainerView(title: ConstantString.cashFlowForecast) {
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
                    .frame(height: 220)
                }
            }
        }
    }
}

// MARK: - Reusable Chart Wrapper

struct ChartContainerView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(title)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            content()
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
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
