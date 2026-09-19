//
//  DashboardKPICard.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct KeyMetricsGridSection: View {
    let kpis: DashboardKPIMetrics

    public init(kpis: DashboardKPIMetrics) {
        self.kpis = kpis
    }

    public var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                // Card 1: TOTAL SALES
                if let sales = kpis.totalSales {
                    MetricCompactCard(
                        title: "TOTAL SALES",
                        amount: sales.formattedAmount,
                        badgeText: sales.trendText,
                        badgeColor: sales.isPositiveTrend ? Color.green : Color.red,
                        topBadge: nil
                    )
                }

                // Card 2: REVENUE
                if let revenue = kpis.revenueOverview {
                    MetricCompactCard(
                        title: "REVENUE",
                        amount: revenue.formattedAmount,
                        badgeText: revenue.trendText,
                        badgeColor: revenue.isPositiveTrend ? Color.green : Color.red,
                        topBadge: nil
                    )
                }

                // Card 3: PENDING PAY
                if let pending = kpis.pendingPayments {
                    MetricCompactCard(
                        title: "PENDING PAY",
                        amount: pending.formattedAmount,
                        badgeText: pending.trendText,
                        badgeColor: Color.green,
                        topBadge: pending.invoiceBadge
                    )
                }

                // Card 4: ORDERS
                if let orders = kpis.ordersSummary {
                    MetricCompactCard(
                        title: "ORDERS",
                        amount: orders.countText,
                        badgeText: orders.targetBadge,
                        badgeColor: Color.secondary,
                        topBadge: orders.pendingBadge
                    )
                }
            }

            // Carousel Page Indicator Dots
            HStack(spacing: 5) {
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 14, height: 4)
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 4, height: 4)
            }
            .padding(.top, 2)
        }
    }
}

struct MetricCompactCard: View {
    let title: String
    let amount: String
    let badgeText: String
    let badgeColor: Color
    let topBadge: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Row: Title & Optional Top Right Badge
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                if let topBadge = topBadge {
                    Text(topBadge)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
            }

            // Amount Value
            Text(amount)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            // Bottom Badge (Trend or Target)
            HStack {
                Text(badgeText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(badgeColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badgeColor.opacity(0.12))
                    .clipShape(Capsule())

                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
        )
    }
}
