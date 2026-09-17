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
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Text(ConstantString.recentActivity)
                    .font(CommonFont.subheadline)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)
                Spacer()
                Text("Swipe")
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.secondaryText)
            }
            .padding(.horizontal, CommonSpacing.xs)

            if activities.isEmpty {
                Text(ConstantString.emptyMessage)
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
                    .padding(.vertical, CommonSpacing.sm)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: CommonSpacing.sm) {
                        ForEach(activities) { activity in
                            HStack(spacing: CommonSpacing.sm) {
                                Image(systemName: iconName(for: activity.category))
                                    .font(.caption)
                                    .foregroundColor(iconColor(for: activity.category))
                                    .frame(width: 28, height: 28)
                                    .background(iconColor(for: activity.category).opacity(0.12))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(activity.title)
                                            .font(CommonFont.caption)
                                            .bold()
                                            .foregroundColor(CommonColor.primaryText)
                                            .lineLimit(1)

                                        Spacer()

                                        Text(activity.timestamp)
                                            .font(CommonFont.caption2)
                                            .foregroundColor(CommonColor.secondaryText)
                                    }

                                    Text(activity.detail)
                                        .font(CommonFont.caption2)
                                        .foregroundColor(CommonColor.secondaryText)
                                        .lineLimit(1)
                                }
                            }
                            .padding(CommonSpacing.sm)
                            .frame(width: 210, alignment: .leading)
                            .background(CommonColor.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 2)
                }
            }
        }
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
