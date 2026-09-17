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
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundColor(iconColor)
                    .padding(CommonSpacing.xs)
                    .background(iconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusSm))

                Text(title)
                    .font(CommonFont.subheadline)
                    .foregroundColor(CommonColor.secondaryText)
                    .lineLimit(1)

                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(CommonFont.kpiValue)
                    .foregroundColor(CommonColor.primaryText)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Spacer()

                if let trend = trendPercentage {
                    HStack(spacing: 2) {
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "%.1f%%", abs(trend)))
                    }
                    .font(CommonFont.caption)
                    .padding(.horizontal, CommonSpacing.xs)
                    .padding(.vertical, 2)
                    .foregroundColor(trend >= 0 ? CommonColor.success : CommonColor.danger)
                    .background((trend >= 0 ? CommonColor.success : CommonColor.danger).opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
            }

            if let comparison = trendComparison {
                Text(comparison)
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.secondaryText)
            }

            if let sparkline = sparklineData, !sparkline.isEmpty {
                SparklineView(data: sparkline)
                    .frame(height: 24)
                    .padding(.top, CommonSpacing.xs)
            }
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Business Overview KPI Card

public struct BusinessOverviewKPICard: View {
    let metric: KPIBusinessOverviewMetric

    public init(metric: KPIBusinessOverviewMetric) {
        self.metric = metric
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundColor(CommonColor.primary)
                    .padding(CommonSpacing.xs)
                    .background(CommonColor.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusSm))

                Text(ConstantString.businessOverview)
                    .font(CommonFont.subheadline)
                    .foregroundColor(CommonColor.secondaryText)

                Spacer()
            }

            HStack {
                Text(String(format: "%.0f%% of %.0f%%", metric.achievementPercentage, metric.target))
                    .font(CommonFont.kpiValue)
                    .foregroundColor(CommonColor.primaryText)

                Spacer()
            }

            ProgressView(value: min(max(metric.achievementPercentage / max(metric.target, 1.0), 0.0), 1.0))
                .tint(CommonColor.primary)

            HStack {
                Text("\(ConstantString.achievementTarget): \(CommonCurrencyFormatter.format(metric.currentAchievement)) / \(CommonCurrencyFormatter.format(metric.target))")
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
            }
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
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
            .stroke(CommonColor.primary, lineWidth: 2)
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
