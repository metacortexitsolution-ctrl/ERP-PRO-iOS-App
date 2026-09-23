//
//  DashboardKPICard.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import Combine

final class KeyMetricsViewState: ObservableObject {
    @Published var currentPage: Int = 0
}

public struct KeyMetricsGridSection: View {
    let kpis: DashboardKPIMetrics
    @StateObject private var viewState = KeyMetricsViewState()

    public init(kpis: DashboardKPIMetrics) {
        self.kpis = kpis
    }

    private var cardItems: [MetricCardData] {
        var items: [MetricCardData] = []
        
        // 1. Total Sales
        if let sales = kpis.totalSales {
            items.append(MetricCardData(
                id: "sales",
                title: "Total Sales",
                amount: sales.formattedAmount,
                trendBadge: sales.trendText,
                isPositiveTrend: sales.isPositiveTrend,
                iconName: "indianrupeesign",
                iconColor: Color(red: 0.15, green: 0.45, blue: 0.95),
                iconBgColor: Color(red: 0.15, green: 0.45, blue: 0.95).opacity(0.12),
                sparklineData: [10, 16, 14, 22, 19, 28, 34],
                sparklineColor: Color(red: 0.25, green: 0.52, blue: 0.95)
            ))
        }
        
        // 2. Revenue Overview
        if let revenue = kpis.revenueOverview {
            items.append(MetricCardData(
                id: "revenue",
                title: "Revenue Overview",
                amount: revenue.formattedAmount,
                trendBadge: revenue.trendText,
                isPositiveTrend: revenue.isPositiveTrend,
                iconName: "arrow.up.right",
                iconColor: Color(red: 0.1, green: 0.78, blue: 0.65),
                iconBgColor: Color(red: 0.1, green: 0.78, blue: 0.65).opacity(0.15),
                sparklineData: [12, 18, 15, 24, 22, 30, 38],
                sparklineColor: Color(red: 0.1, green: 0.78, blue: 0.65)
            ))
        }
        
        // 3. Pending Payments
        if let pending = kpis.pendingPayments {
            items.append(MetricCardData(
                id: "pending",
                title: "Pending Payments",
                amount: pending.formattedAmount,
                titleBadge: pending.invoiceBadge,
                titleBadgeColor: Color(red: 0.92, green: 0.48, blue: 0.05),
                trendBadge: pending.trendText,
                isPositiveTrend: pending.isPositiveTrend,
                iconName: "wallet.pass.fill",
                iconColor: Color(red: 0.92, green: 0.62, blue: 0.1),
                iconBgColor: Color(red: 0.98, green: 0.9, blue: 0.65).opacity(0.4),
                sparklineData: [32, 28, 24, 20, 22, 16, 12],
                sparklineColor: Color(red: 0.92, green: 0.48, blue: 0.05)
            ))
        }
        
        // 4. Orders Summary
        if let orders = kpis.ordersSummary {
            items.append(MetricCardData(
                id: "orders",
                title: "Orders Summary",
                amount: orders.countText,
                titleBadge: orders.pendingBadge,
                titleBadgeColor: Color(red: 0.52, green: 0.25, blue: 0.9),
                iconName: "clipboard.fill",
                iconColor: Color(red: 0.52, green: 0.25, blue: 0.9),
                iconBgColor: Color(red: 0.52, green: 0.25, blue: 0.9).opacity(0.12),
                sparklineData: [10, 15, 12, 20, 25, 22, 30],
                sparklineColor: Color(red: 0.52, green: 0.25, blue: 0.9)
            ))
        }

        // 5. Inventory Summary
        if let inv = kpis.inventorySummary {
            items.append(MetricCardData(
                id: "inventory",
                title: "Inventory Summary",
                amount: inv.countText,
                iconName: "shippingbox.fill",
                iconColor: Color(red: 0.25, green: 0.52, blue: 0.95),
                iconBgColor: Color(red: 0.25, green: 0.52, blue: 0.95).opacity(0.12),
                sparklineData: [14, 18, 16, 22, 25, 29, 36],
                sparklineColor: Color(red: 0.25, green: 0.52, blue: 0.95)
            ))
        }

        // 6. Customer Activity
        if let cust = kpis.customerActivity {
            items.append(MetricCardData(
                id: "customer",
                title: "Customer Activity",
                amount: cust.activeText,
                titleBadge: cust.newBadge,
                titleBadgeColor: Color(red: 0.1, green: 0.72, blue: 0.3),
                iconName: "person.2.fill",
                iconColor: Color(red: 0.1, green: 0.72, blue: 0.3),
                iconBgColor: Color(red: 0.1, green: 0.72, blue: 0.3).opacity(0.15),
                sparklineData: [10, 16, 20, 24, 28, 34, 40],
                sparklineColor: Color(red: 0.1, green: 0.72, blue: 0.3)
            ))
        }

        // 7. Low Stock Alerts
        if let stock = kpis.lowStockAlerts {
            items.append(MetricCardData(
                id: "stock",
                title: "Low Stock Alerts",
                amount: stock.countText,
                iconName: "exclamationmark.triangle.fill",
                iconColor: Color(red: 0.9, green: 0.25, blue: 0.25),
                iconBgColor: Color(red: 0.9, green: 0.25, blue: 0.25).opacity(0.12),
                sparklineData: [28, 24, 22, 18, 16, 12, 8],
                sparklineColor: Color(red: 0.9, green: 0.25, blue: 0.25)
            ))
        }

        // 8. Business Overview
        if let biz = kpis.businessOverview {
            items.append(MetricCardData(
                id: "business",
                title: "Business Overview",
                amount: biz.percentageText,
                titleBadge: biz.targetBadge,
                titleBadgeColor: Color(red: 0.95, green: 0.45, blue: 0.05),
                iconName: "target",
                iconColor: Color(red: 0.95, green: 0.45, blue: 0.05),
                iconBgColor: Color(red: 0.95, green: 0.45, blue: 0.05).opacity(0.12),
                sparklineData: [20, 35, 48, 62, 74, 85, 94],
                sparklineColor: Color(red: 0.95, green: 0.45, blue: 0.05)
            ))
        }

        return items
    }

    private var pages: [[MetricCardData]] {
        stride(from: 0, to: cardItems.count, by: 4).map {
            Array(cardItems[$0..<min($0 + 4, cardItems.count)])
        }
    }

    public var body: some View {
        VStack(spacing: 8) {
            if !pages.isEmpty {
                TabView(selection: $viewState.currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { pageIndex, pageCards in
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(pageCards) { card in
                                MetricCompactCard(card: card)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .tag(pageIndex)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 300)

                if pages.count > 1 {
                    // Carousel Page Indicator Dots
                    HStack(spacing: 6) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == viewState.currentPage ? Color.blue : Color.gray.opacity(0.35))
                                .frame(width: index == viewState.currentPage ? 18 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: viewState.currentPage)
                                .onTapGesture {
                                    withAnimation {
                                        viewState.currentPage = index
                                    }
                                }
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 2)
                }
            }
        }
    }
}

struct MetricCardData: Identifiable {
    let id: String
    let title: String
    let amount: String
    var titleBadge: String? = nil
    var titleBadgeColor: Color = .blue
    var trendBadge: String? = nil
    var isPositiveTrend: Bool = true
    let iconName: String
    let iconColor: Color
    let iconBgColor: Color
    let sparklineData: [CGFloat]
    let sparklineColor: Color
}

struct MetricCompactCard: View {
    let card: MetricCardData

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Row: Title on Left, Optional Badge on Right
            HStack(alignment: .center, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if let titleBadge = card.titleBadge {
                    Spacer(minLength: 4)

                    Text(titleBadge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(card.titleBadgeColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(card.titleBadgeColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer(minLength: 4)

            // Amount Value
            Text(card.amount)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            // Bottom Row: Trend Badge (if present)
            if let trendBadge = card.trendBadge {
                Text(trendBadge)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(card.isPositiveTrend ? Color(red: 0.05, green: 0.65, blue: 0.3) : Color(red: 0.85, green: 0.2, blue: 0.2))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((card.isPositiveTrend ? Color.green : Color.red).opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}

struct SparklineView: View {
    let data: [CGFloat]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            if data.count > 1 {
                let minVal = data.min() ?? 0
                let maxVal = data.max() ?? 1
                let range = max(maxVal - minVal, 1.0)
                
                Path { path in
                    let points: [CGPoint] = data.enumerated().map { index, val in
                        let x = geo.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let normalizedY = (val - minVal) / range
                        let y = geo.size.height * (1.0 - normalizedY)
                        return CGPoint(x: x, y: y)
                    }
                    
                    if let first = points.first {
                        path.move(to: first)
                        for i in 1..<points.count {
                            let p0 = points[i - 1]
                            let p1 = points[i]
                            let midPoint = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
                            path.addQuadCurve(to: midPoint, control: p0)
                            path.addQuadCurve(to: p1, control: midPoint)
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            }
        }
    }
}
