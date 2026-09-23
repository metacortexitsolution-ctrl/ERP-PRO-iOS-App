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
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            // Priority Header Line
            HStack {
                Text("Priority Alerts")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9, weight: .bold))
                    Text("Actionable")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Color.red)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.12))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 2)

            // Alert List Container
            VStack(spacing: 0) {
                ForEach(Array(alerts.enumerated()), id: \.element.id) { index, alert in
                    AlertRowItem(alert: alert)
                    
                    if index < alerts.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }

                Divider()

                // View All Link
                Button {
                    // View all alerts action
                } label: {
                    HStack {
                        Spacer()
                        Text("View all alerts →")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
            }
            .background(CommonColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: CommonSpacing.cardCornerRadius, style: .continuous)
                    .stroke(CommonColor.cardBorder, lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
    }
}

struct AlertRowItem: View {
    let alert: AlertBannerItem

    var body: some View {
        HStack(spacing: 12) {
            // Tinted Icon Circle
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 28, height: 28)

                Image(systemName: alert.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(iconForegroundColor)
            }

            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                if alert.severity == "danger" {
                    Text(alert.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.red)
                } else {
                    Text(alert.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var iconBackgroundColor: Color {
        switch alert.severity.lowercased() {
        case "danger":
            return Color.red.opacity(0.12)
        case "purple":
            return Color.purple.opacity(0.12)
        default:
            return Color.blue.opacity(0.12)
        }
    }

    private var iconForegroundColor: Color {
        switch alert.severity.lowercased() {
        case "danger":
            return Color.red
        case "purple":
            return Color.purple
        default:
            return Color.blue
        }
    }
}
