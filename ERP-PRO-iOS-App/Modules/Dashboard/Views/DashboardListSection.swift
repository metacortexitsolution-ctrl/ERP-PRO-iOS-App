//
//  DashboardListSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardListSection: View {
    let pipeline: OrdersPipelineSummary?
    let topCustomers: [TopCustomer]?
    let pendingApprovals: [PendingApproval]?
    let dealerPerformance: [DealerPerformanceItem]?
    let supportTicketSummary: SupportTicketSummary?
    let lowStockItems: [LowStockItem]?

    public init(
        pipeline: OrdersPipelineSummary?,
        topCustomers: [TopCustomer]?,
        pendingApprovals: [PendingApproval]?,
        dealerPerformance: [DealerPerformanceItem]?,
        supportTicketSummary: SupportTicketSummary?,
        lowStockItems: [LowStockItem]?
    ) {
        self.pipeline = pipeline
        self.topCustomers = topCustomers
        self.pendingApprovals = pendingApprovals
        self.dealerPerformance = dealerPerformance
        self.supportTicketSummary = supportTicketSummary
        self.lowStockItems = lowStockItems
    }

    public var body: some View {
        VStack(spacing: CommonSpacing.md) {
            // 1. Orders Pipeline
            if let pipeline = pipeline {
                OrdersPipelineView(pipeline: pipeline)
            }

            // 2. Pending Approvals (Horizontal Cards)
            if let approvals = pendingApprovals, !approvals.isEmpty {
                PendingApprovalsHorizontalView(approvals: approvals)
            }

            // 3. Top Customers (Horizontal Cards)
            if let customers = topCustomers, !customers.isEmpty {
                TopCustomersHorizontalView(customers: customers)
            }

            // 4. Dealer Performance (Horizontal Scroll Table)
            if let performance = dealerPerformance, !performance.isEmpty {
                DealerPerformanceTableView(items: performance)
            }

            // 5. Support Ticket Summary
            if let tickets = supportTicketSummary {
                SupportTicketSummaryView(summary: tickets)
            }

            // 6. Low Stock Table (Horizontal Scroll Table)
            if let lowStock = lowStockItems, !lowStock.isEmpty {
                LowStockTableView(items: lowStock)
            }
        }
    }
}

// MARK: - 1. Orders Pipeline View

struct OrdersPipelineView: View {
    let pipeline: OrdersPipelineSummary

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            Text(ConstantString.ordersPipeline)
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(CommonColor.primaryText)

            HStack(spacing: CommonSpacing.xs) {
                PipelineStageBadge(title: ConstantString.pipelineNew, count: pipeline.newCount, color: CommonColor.info)
                PipelineStageBadge(title: ConstantString.pipelineConfirmed, count: pipeline.confirmedCount, color: CommonColor.primary)
                PipelineStageBadge(title: ConstantString.pipelineProcessing, count: pipeline.processingCount, color: CommonColor.warning)
                PipelineStageBadge(title: ConstantString.pipelineShipped, count: pipeline.shippedCount, color: CommonColor.accent)
                PipelineStageBadge(title: ConstantString.pipelineDelivered, count: pipeline.deliveredCount, color: CommonColor.success)
            }
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct PipelineStageBadge: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(color)

            Text(title)
                .font(CommonFont.caption2)
                .foregroundColor(CommonColor.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CommonSpacing.xs)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusSm))
    }
}

// MARK: - 2. Top Customers Horizontal Scroll Cards

struct TopCustomersHorizontalView: View {
    let customers: [TopCustomer]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Text(ConstantString.topCustomers)
                    .font(CommonFont.subheadline)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)
                Spacer()
                Text("Swipe")
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.secondaryText)
            }
            .padding(.horizontal, CommonSpacing.xs)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CommonSpacing.sm) {
                    ForEach(customers) { customer in
                        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                            HStack {
                                Text(customer.name)
                                    .font(CommonFont.subheadline)
                                    .bold()
                                    .foregroundColor(CommonColor.primaryText)
                                    .lineLimit(1)
                                Spacer()
                                HealthBadge(status: customer.paymentHealth)
                            }

                            Text(CommonCurrencyFormatter.format(customer.revenue))
                                .font(CommonFont.kpiSubValue)
                                .foregroundColor(CommonColor.primary)
                        }
                        .padding(CommonSpacing.sm)
                        .frame(width: 170, alignment: .leading)
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

struct HealthBadge: View {
    let status: String

    var body: some View {
        Text(status)
            .font(CommonFont.caption2)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundColor(badgeColor)
            .background(badgeColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch status.lowercased() {
        case "paid": return CommonColor.success
        case "outstanding": return CommonColor.warning
        case "overdue": return CommonColor.danger
        default: return CommonColor.neutral
        }
    }
}

// MARK: - 3. Pending Approvals Horizontal Scroll Cards

struct PendingApprovalsHorizontalView: View {
    let approvals: [PendingApproval]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Text(ConstantString.pendingApprovals)
                    .font(CommonFont.subheadline)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)
                Spacer()
                Text("\(approvals.count) pending")
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.warning)
            }
            .padding(.horizontal, CommonSpacing.xs)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CommonSpacing.sm) {
                    ForEach(approvals) { item in
                        VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                            HStack {
                                Text(item.type)
                                    .font(CommonFont.caption2)
                                    .bold()
                                    .foregroundColor(CommonColor.warning)
                                Spacer()
                                Text(item.date)
                                    .font(CommonFont.caption2)
                                    .foregroundColor(CommonColor.secondaryText)
                            }

                            Text(item.title)
                                .font(CommonFont.subheadline)
                                .bold()
                                .foregroundColor(CommonColor.primaryText)
                                .lineLimit(1)

                            HStack {
                                Text(item.requestedBy)
                                    .font(CommonFont.caption)
                                    .foregroundColor(CommonColor.secondaryText)
                                Spacer()
                                Text(CommonCurrencyFormatter.format(item.amount))
                                    .font(CommonFont.subheadline)
                                    .bold()
                                    .foregroundColor(CommonColor.primaryText)
                            }
                        }
                        .padding(CommonSpacing.sm)
                        .frame(width: 220, alignment: .leading)
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

// MARK: - 4. Dealer Performance Table

struct DealerPerformanceTableView: View {
    let items: [DealerPerformanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            Text(ConstantString.dealerPerformance)
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(CommonColor.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                    HStack {
                        Text(ConstantString.region).frame(width: 80, alignment: .leading)
                        Text(ConstantString.mtdOrders).frame(width: 70, alignment: .trailing)
                        Text(ConstantString.sales).frame(width: 90, alignment: .trailing)
                        Text(ConstantString.targetAchievement).frame(width: 70, alignment: .trailing)
                        Text(ConstantString.commissionDue).frame(width: 90, alignment: .trailing)
                    }
                    .font(CommonFont.caption2)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)

                    Divider()

                    ForEach(items) { item in
                        HStack {
                            Text(item.region).frame(width: 80, alignment: .leading)
                            Text("\(item.mtdOrders)").frame(width: 70, alignment: .trailing)
                            Text(CommonCurrencyFormatter.format(item.sales)).frame(width: 90, alignment: .trailing)
                            Text(String(format: "%.0f%%", item.targetAchievementPercentage)).frame(width: 70, alignment: .trailing)
                            Text(CommonCurrencyFormatter.format(item.commissionDue)).frame(width: 90, alignment: .trailing)
                        }
                        .font(CommonFont.caption)
                        .padding(.vertical, 2)
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

// MARK: - 5. Support Ticket Summary

struct SupportTicketSummaryView: View {
    let summary: SupportTicketSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ConstantString.supportTicketSummary)
                    .font(CommonFont.subheadline)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)

                Text("\(summary.openTicketsCount) Open Tickets • Priority: \(summary.priority)")
                    .font(CommonFont.caption)
                    .foregroundColor(CommonColor.secondaryText)
            }

            Spacer()

            SLABadge(status: summary.slaStatus)
        }
        .padding(CommonSpacing.md)
        .background(CommonColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusMd))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct SLABadge: View {
    let status: String

    var body: some View {
        Text(status)
            .font(CommonFont.caption2)
            .bold()
            .padding(.horizontal, CommonSpacing.sm)
            .padding(.vertical, 4)
            .foregroundColor(badgeColor)
            .background(badgeColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch status.lowercased() {
        case "on track": return CommonColor.success
        case "at risk": return CommonColor.warning
        case "breached": return CommonColor.danger
        default: return CommonColor.neutral
        }
    }
}

// MARK: - 6. Low Stock Table

struct LowStockTableView: View {
    let items: [LowStockItem]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.sm) {
            HStack {
                Text(ConstantString.lowStockTable)
                    .font(CommonFont.subheadline)
                    .bold()
                    .foregroundColor(CommonColor.primaryText)

                Spacer()

                Text("\(items.count) items")
                    .font(CommonFont.caption2)
                    .foregroundColor(CommonColor.danger)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                    HStack {
                        Text(ConstantString.sku).frame(width: 90, alignment: .leading)
                        Text(ConstantString.productName).frame(width: 140, alignment: .leading)
                        Text(ConstantString.category).frame(width: 90, alignment: .leading)
                        Text(ConstantString.stockLevel).frame(width: 70, alignment: .trailing)
                        Text(ConstantString.reorderLevel).frame(width: 80, alignment: .trailing)
                        Text(ConstantString.warehouse).frame(width: 90, alignment: .leading)
                    }
                    .font(CommonFont.caption2)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)

                    Divider()

                    ForEach(items) { item in
                        HStack {
                            Text(item.sku).frame(width: 90, alignment: .leading)
                            Text(item.productName).frame(width: 140, alignment: .leading)
                            Text(item.category).frame(width: 90, alignment: .leading)
                            Text("\(item.stockLevel)")
                                .bold()
                                .foregroundColor(CommonColor.danger)
                                .frame(width: 70, alignment: .trailing)
                            Text("\(item.reorderLevel)").frame(width: 80, alignment: .trailing)
                            Text(item.warehouse).frame(width: 90, alignment: .leading)
                        }
                        .font(CommonFont.caption)
                        .padding(.vertical, 2)
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
