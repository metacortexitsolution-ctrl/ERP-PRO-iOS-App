//
//  DashboardKPICard.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardKPICard: View {
    let title: String
    let value: String
    let subtitle: String?
    let trendPercentage: Double?
    let trendComparison: String?
    let sparklineData: [Double]?
    let iconName: String
    let iconColor: Color

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        trendPercentage: Double? = nil,
        trendComparison: String? = nil,
        sparklineData: [Double]? = nil,
        iconName: String,
        iconColor: Color = CommonColor.primary
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trendPercentage = trendPercentage
        self.trendComparison = trendComparison
        self.sparklineData = sparklineData
        self.iconName = iconName
        self.iconColor = iconColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
            // Top Row: Title + Circular Icon
            HStack(alignment: .top) {
                Text(title)
                    .font(CommonFont.caption)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)
                    .lineLimit(1)

                Spacer(minLength: 4)

                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(iconColor)
                }
            }

            // Value + Trend Badge
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(CommonFont.kpiValue)
                    .foregroundColor(CommonColor.primaryText)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)

                Spacer(minLength: 2)

                if let trend = trendPercentage {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "%.1f%%", abs(trend)))
                    }
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .foregroundColor(trend >= 0 ? CommonColor.success : CommonColor.danger)
                    .background((trend >= 0 ? CommonColor.success : CommonColor.danger).opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            Spacer(minLength: 0)

            // Bottom Row: Subtitle & Sparkline
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(CommonFont.caption2)
                            .foregroundColor(CommonColor.secondaryText)
                            .lineLimit(1)
                    }

                    if let comparison = trendComparison {
                        Text(comparison)
                            .font(.system(size: 9))
                            .foregroundColor(CommonColor.secondaryText.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 4)

                if let sparkline = sparklineData, !sparkline.isEmpty {
                    SparklineView(data: sparkline)
                        .frame(width: 44, height: 18)
                } else {
                    Color.clear
                        .frame(width: 44, height: 18)
                }
            }
        }
        .padding(CommonSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 112, maxHeight: .infinity, alignment: .topLeading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Business Overview KPI Card

public struct BusinessOverviewKPICard: View {
    let metric: KPIBusinessOverviewMetric

    public init(metric: KPIBusinessOverviewMetric) {
        self.metric = metric
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
            // Top Row: Title + Circular Icon
            HStack(alignment: .top) {
                Text(ConstantString.businessOverview)
                    .font(CommonFont.caption)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)
                    .lineLimit(1)

                Spacer(minLength: 4)

                ZStack {
                    Circle()
                        .fill(CommonColor.primary.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(CommonColor.primary)
                }
            }

            // Value + Target Badge
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "%.0f%%", metric.achievementPercentage))
                    .font(CommonFont.kpiValue)
                    .foregroundColor(CommonColor.primaryText)

                Spacer(minLength: 2)

                Text("Target \(String(format: "%.0f%%", metric.target))")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .foregroundColor(CommonColor.primary)
                    .background(CommonColor.primary.opacity(0.12))
                    .clipShape(Capsule())
            }

            Spacer(minLength: 0)

            // Progress & Subtitle
            VStack(alignment: .leading, spacing: 3) {
                ProgressView(value: min(max(metric.achievementPercentage / max(metric.target, 1.0), 0.0), 1.0))
                    .tint(CommonColor.primary)

                Text("\(CommonCurrencyFormatter.format(metric.currentAchievement)) / \(CommonCurrencyFormatter.format(metric.target))")
                    .font(.system(size: 9))
                    .foregroundColor(CommonColor.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(CommonSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 112, maxHeight: .infinity, alignment: .topLeading)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Sparkline Visualization

struct SparklineView: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geometry in
            let points = normalizePoints(in: geometry.size)
            Path { path in
                guard points.count > 1 else { return }
                path.move(to: points[0])
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }
            }
            .stroke(CommonColor.primary, lineWidth: 1.5)
        }
    }

    private func normalizePoints(in size: CGSize) -> [CGPoint] {
        guard data.count > 1 else { return [] }
        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 1
        let range = maxVal - minVal == 0 ? 1 : maxVal - minVal

        let stepX = size.width / CGFloat(data.count - 1)

        return data.enumerated().map { idx, val in
            let x = CGFloat(idx) * stepX
            let y = size.height - (CGFloat((val - minVal) / range) * size.height)
            return CGPoint(x: x, y: y)
        }
    }
}
