//
//  DashboardAlertSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardAlertSection: View {
    let alerts: [AlertBannerItem]
    var onAlertSelect: ((AlertBannerItem) -> Void)?

    @State private var dismissedAlertIDs: Set<String> = []

    public init(alerts: [AlertBannerItem], onAlertSelect: ((AlertBannerItem) -> Void)? = nil) {
        self.alerts = alerts
        self.onAlertSelect = onAlertSelect
    }

    private var visibleAlerts: [AlertBannerItem] {
        alerts.filter { !dismissedAlertIDs.contains($0.id) }
    }

    public var body: some View {
        if !visibleAlerts.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(visibleAlerts.enumerated()), id: \.element.id) { index, alert in
                    AlertRowItem(
                        alert: alert,
                        onDismiss: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                _ = dismissedAlertIDs.insert(alert.id)
                            }
                        },
                        onSelect: {
                            onAlertSelect?(alert)
                        }
                    )
                    
                    if index < visibleAlerts.count - 1 {
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
    let onDismiss: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Main content area tap target (redirection to related data)
            Button(action: onSelect) {
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
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Close (X) button action
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(6)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
