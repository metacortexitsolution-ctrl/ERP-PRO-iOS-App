//
//  DashboardAlertSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardAlertSection: View {
    let alerts: [AlertBannerItem]

    public init(alerts: [AlertBannerItem]) {
        self.alerts = alerts
    }

    public var body: some View {
        if !alerts.isEmpty {
            if alerts.count == 1 {
                AlertBannerRow(alert: alerts[0])
            } else {
                TabView {
                    ForEach(alerts) { alert in
                        AlertBannerRow(alert: alert)
                            .padding(.horizontal, 2)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 95)
            }
        }
    }
}

struct AlertBannerRow: View {
    let alert: AlertBannerItem

    var body: some View {
        HStack(spacing: CommonSpacing.md) {
            Image(systemName: iconName(for: alert.severity))
                .font(.headline)
                .foregroundColor(severityColor(for: alert.severity))

            VStack(alignment: .leading, spacing: 2) {
                Text(alert.type.uppercased())
                    .font(CommonFont.caption2)
                    .bold()
                    .foregroundColor(severityColor(for: alert.severity))

                Text(alert.message)
                    .font(CommonFont.subheadline)
                    .foregroundColor(CommonColor.primaryText)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(CommonSpacing.md)
        .background(severityColor(for: alert.severity).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd)
                .stroke(severityColor(for: alert.severity).opacity(0.25), lineWidth: 1)
        )
    }

    private func iconName(for severity: String) -> String {
        switch severity.lowercased() {
        case "critical", "danger", "error":
            return "exclamationmark.triangle.fill"
        case "warning":
            return "exclamationmark.circle.fill"
        default:
            return "info.circle.fill"
        }
    }

    private func severityColor(for severity: String) -> Color {
        switch severity.lowercased() {
        case "critical", "danger", "error":
            return CommonColor.danger
        case "warning":
            return CommonColor.warning
        default:
            return CommonColor.info
        }
    }
}
