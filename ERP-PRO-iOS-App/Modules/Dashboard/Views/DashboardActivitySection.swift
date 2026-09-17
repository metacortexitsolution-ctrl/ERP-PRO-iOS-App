//
//  DashboardActivitySection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardActivitySection: View {
    let activities: [RecentActivityItem]

    public init(activities: [RecentActivityItem]) {
        self.activities = activities
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.recentActivity)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            if activities.isEmpty {
                Text(ConstantString.emptyMessage)
                    .font(CommonFont.subheadline)
                    .foregroundColor(CommonColor.secondaryText)
                    .padding(.vertical, CommonSpacing.md)
            } else {
                VStack(spacing: CommonSpacing.sm) {
                    ForEach(activities) { activity in
                        ActivityRowView(activity: activity)
                        if activity.id != activities.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct ActivityRowView: View {
    let activity: RecentActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: CommonSpacing.md) {
            Image(systemName: iconName(for: activity.category))
                .font(.body)
                .foregroundColor(iconColor(for: activity.category))
                .frame(width: 32, height: 32)
                .background(iconColor(for: activity.category).opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.title)
                        .font(CommonFont.subheadline)
                        .bold()
                        .foregroundColor(CommonColor.primaryText)

                    Spacer()

                    Text(activity.timestamp)
                        .font(CommonFont.caption2)
                        .foregroundColor(CommonColor.secondaryText)
                }

                Text(activity.detail)
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
            }
        }
        .padding(.vertical, CommonSpacing.xs)
    }

    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "order", "orders":
            return "cart.fill"
        case "payment", "payments":
            return "creditcard.fill"
        case "inventory":
            return "box.truck.fill"
        case "expense", "expenses":
            return "dollarsign.circle.fill"
        default:
            return "clock.fill"
        }
    }

    private func iconColor(for category: String) -> Color {
        switch category.lowercased() {
        case "order", "orders":
            return CommonColor.primary
        case "payment", "payments":
            return CommonColor.success
        case "inventory":
            return CommonColor.warning
        case "expense", "expenses":
            return CommonColor.danger
        default:
            return CommonColor.neutral
        }
    }
}
