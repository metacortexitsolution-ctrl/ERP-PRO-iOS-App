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
        VStack(spacing: CommonSpacing.lg) {
            // 1. Orders Pipeline
            if let pipeline = pipeline {
                OrdersPipelineView(pipeline: pipeline)
            }

            // 2. Top Customers
            if let customers = topCustomers, !customers.isEmpty {
                TopCustomersListView(customers: customers)
            }

            // 3. Pending Approvals
            if let approvals = pendingApprovals, !approvals.isEmpty {
                PendingApprovalsListView(approvals: approvals)
            }

            // 4. Dealer Performance
            if let performance = dealerPerformance, !performance.isEmpty {
                DealerPerformanceTableView(items: performance)
            }

            // 5. Support Ticket Summary
            if let tickets = supportTicketSummary {
                SupportTicketSummaryView(summary: tickets)
            }

            // 6. Low Stock Table
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
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.ordersPipeline)
                .font(CommonFont.title3)
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
        VStack(spacing: 4) {
            Text("\(count)")
                .font(CommonFont.subheadline)
                .bold()
                .foregroundColor(color)

            Text(title)
                .font(CommonFont.caption2)
                .foregroundColor(CommonColor.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CommonSpacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CommonSpacing.cornerRadiusSm))
    }
}

// MARK: - 2. Top Customers List

struct TopCustomersListView: View {
    let customers: [TopCustomer]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.topCustomers)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            VStack(spacing: CommonSpacing.sm) {
                ForEach(customers) { customer in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(customer.name)
                                .font(CommonFont.subheadline)
                                .bold()
                                .foregroundColor(CommonColor.primaryText)
                            Text(CommonCurrencyFormatter.format(customer.revenue))
                                .font(CommonFont.caption)
                                .foregroundColor(CommonColor.secondaryText)
                        }
                        Spacer()
                        HealthBadge(status: customer.paymentHealth)
                    }
                    if customer.id != customers.last?.id {
                        Divider()
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

struct HealthBadge: View {
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
        case "paid": return CommonColor.success
        case "outstanding": return CommonColor.warning
        case "overdue": return CommonColor.danger
        default: return CommonColor.neutral
        }
    }
}

// MARK: - 3. Pending Approvals List

struct PendingApprovalsListView: View {
    let approvals: [PendingApproval]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.pendingApprovals)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            VStack(spacing: CommonSpacing.sm) {
                ForEach(approvals) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(CommonFont.subheadline)
                                .bold()
                                .foregroundColor(CommonColor.primaryText)
                            Text("\(item.type) • \(item.requestedBy) • \(item.date)")
                                .font(CommonFont.caption)
                                .foregroundColor(CommonColor.secondaryText)
                        }
                        Spacer()
                        Text(CommonCurrencyFormatter.format(item.amount))
                            .font(CommonFont.subheadline)
                            .bold()
                            .foregroundColor(CommonColor.primaryText)
                    }
                    if item.id != approvals.last?.id {
                        Divider()
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

// MARK: - 4. Dealer Performance Table

struct DealerPerformanceTableView: View {
    let items: [DealerPerformanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.dealerPerformance)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                    HStack {
                        Text(ConstantString.region).frame(width: 100, alignment: .leading)
                        Text(ConstantString.mtdOrders).frame(width: 80, alignment: .trailing)
                        Text(ConstantString.sales).frame(width: 100, alignment: .trailing)
                        Text(ConstantString.targetAchievement).frame(width: 80, alignment: .trailing)
                        Text(ConstantString.commissionDue).frame(width: 100, alignment: .trailing)
                    }
                    .font(CommonFont.caption)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)

                    Divider()

                    ForEach(items) { item in
                        HStack {
                            Text(item.region).frame(width: 100, alignment: .leading)
                            Text("\(item.mtdOrders)").frame(width: 80, alignment: .trailing)
                            Text(CommonCurrencyFormatter.format(item.sales)).frame(width: 100, alignment: .trailing)
                            Text(String(format: "%.0f%%", item.targetAchievementPercentage)).frame(width: 80, alignment: .trailing)
                            Text(CommonCurrencyFormatter.format(item.commissionDue)).frame(width: 100, alignment: .trailing)
                        }
                        .font(CommonFont.caption)
                        .padding(.vertical, 4)
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
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.supportTicketSummary)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(summary.openTicketsCount) Open Tickets")
                        .font(CommonFont.subheadline)
                        .bold()
                        .foregroundColor(CommonColor.primaryText)
                    Text("Priority: \(summary.priority)")
                        .font(CommonFont.caption)
                        .foregroundColor(CommonColor.secondaryText)
                }

                Spacer()

                SLABadge(status: summary.slaStatus)
            }
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
        VStack(alignment: .leading, spacing: CommonSpacing.md) {
            Text(ConstantString.lowStockTable)
                .font(CommonFont.title3)
                .foregroundColor(CommonColor.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: CommonSpacing.xs) {
                    HStack {
                        Text(ConstantString.sku).frame(width: 80, alignment: .leading)
                        Text(ConstantString.productName).frame(width: 140, alignment: .leading)
                        Text(ConstantString.category).frame(width: 100, alignment: .leading)
                        Text(ConstantString.stockLevel).frame(width: 80, alignment: .trailing)
                        Text(ConstantString.reorderLevel).frame(width: 90, alignment: .trailing)
                        Text(ConstantString.warehouse).frame(width: 100, alignment: .leading)
                    }
                    .font(CommonFont.caption)
                    .bold()
                    .foregroundColor(CommonColor.secondaryText)

                    Divider()

                    ForEach(items) { item in
                        HStack {
                            Text(item.sku).frame(width: 80, alignment: .leading)
                            Text(item.productName).frame(width: 140, alignment: .leading)
                            Text(item.category).frame(width: 100, alignment: .leading)
                            Text("\(item.stockLevel)")
                                .bold()
                                .foregroundColor(CommonColor.danger)
                                .frame(width: 80, alignment: .trailing)
                            Text("\(item.reorderLevel)").frame(width: 90, alignment: .trailing)
                            Text(item.warehouse).frame(width: 100, alignment: .leading)
                        }
                        .font(CommonFont.caption)
                        .padding(.vertical, 4)
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
