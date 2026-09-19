//
//  DashboardListSection.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct DashboardListSection: View {
    let performanceMetrics: [PerformanceMetricRow]?
    let pipeline: OrdersPipelineSummary?
    let paymentCollection: PaymentCollectionSummary?
    let pendingApprovals: [PendingApproval]?
    let topCustomers: [TopCustomer]?
    let dealerPerformance: [DealerPerformanceItem]?

    public init(
        performanceMetrics: [PerformanceMetricRow]? = nil,
        pipeline: OrdersPipelineSummary?,
        paymentCollection: PaymentCollectionSummary? = nil,
        pendingApprovals: [PendingApproval]?,
        topCustomers: [TopCustomer]?,
        dealerPerformance: [DealerPerformanceItem]?
    ) {
        self.performanceMetrics = performanceMetrics
        self.pipeline = pipeline
        self.paymentCollection = paymentCollection
        self.pendingApprovals = pendingApprovals
        self.topCustomers = topCustomers
        self.dealerPerformance = dealerPerformance
    }

    public var body: some View {
        VStack(spacing: 16) {
            // 1. Performance Section
            if let metrics = performanceMetrics, !metrics.isEmpty {
                PerformanceSectionView(metrics: metrics)
            }

            // 2. Sales Orders Pipeline
            if let pipeline = pipeline {
                SalesOrdersPipelineView(pipeline: pipeline)
            }

            // 3. Payment Collection
            if let payment = paymentCollection {
                PaymentCollectionView(payment: payment)
            }

            // 4. Pending Approvals
            if let approvals = pendingApprovals, !approvals.isEmpty {
                PendingApprovalsListView(approvals: approvals)
            }

            // 5. Top Customers
            if let customers = topCustomers, !customers.isEmpty {
                TopCustomersListView(customers: customers)
            }

            // 6. Dealer Performance
            if let dealers = dealerPerformance, !dealers.isEmpty {
                DealerPerformanceListView(dealers: dealers)
            }
        }
    }
}

// MARK: - 1. Performance Section

struct PerformanceSectionView: View {
    let metrics: [PerformanceMetricRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Performance")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Year over Year")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, row in
                    HStack {
                        Text(row.title)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.primary)

                        Spacer()

                        Text(row.value)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)

                        Text(row.trend)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if index < metrics.count - 1 {
                        Divider()
                            .padding(.leading, 12)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - 2. Sales Orders Pipeline

struct SalesOrdersPipelineView: View {
    let pipeline: OrdersPipelineSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Sales Orders")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Button("View all →") {}
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 12) {
                HStack(spacing: 4) {
                    PipelineStageItem(stage: "New", count: pipeline.newCount, value: pipeline.newValue, isCompleted: true)
                    PipelineStageItem(stage: "Confirmed", count: pipeline.confirmedCount, value: pipeline.confirmedValue, isCompleted: true)
                    PipelineStageItem(stage: "Processing", count: pipeline.processingCount, value: pipeline.processingValue, isCompleted: true)
                    PipelineStageItem(stage: "Shipped", count: pipeline.shippedCount, value: pipeline.shippedValue, isCompleted: false)
                    PipelineStageItem(stage: "Delivered", count: pipeline.deliveredCount, value: pipeline.deliveredValue, isCompleted: false)
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}

struct PipelineStageItem: View {
    let stage: String
    let count: Int
    let value: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Top Blue Bar
            Rectangle()
                .fill(isCompleted ? Color.blue : Color.blue.opacity(0.3))
                .frame(height: 3)
                .cornerRadius(1.5)

            Text(stage)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)

            Text(value)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 3. Payment Collection

struct PaymentCollectionView: View {
    let payment: PaymentCollectionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Payment Collection")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text(payment.totalInvoiced)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                // Main Stat & Health Badge
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.2f%%", payment.collectedPercentage))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primary)

                        Text("collected")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(payment.statusBadge)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                }

                // Multi-segment progress bar
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geo.size.width * 0.755)

                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: geo.size.width * 0.16)

                        Rectangle()
                            .fill(Color.red)
                    }
                }
                .frame(height: 6)
                .clipShape(Capsule())

                // 3 Stat Columns
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.blue).frame(width: 6, height: 6)
                            Text("Collected")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.collectedAmount)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.purple).frame(width: 6, height: 6)
                            Text("Pending")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.pendingAmount)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Circle().fill(Color.red).frame(width: 6, height: 6)
                            Text("Overdue")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.overdueAmount)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - 4. Pending Approvals List

struct PendingApprovalsListView: View {
    let approvals: [PendingApproval]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Pending Approvals")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Button("View all (\(approvals.count)) →") {}
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 0) {
                ForEach(Array(approvals.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        // Tinted Icon Circle
                        ZStack {
                            Circle()
                                .fill(categoryColor(for: item.iconColorCategory).opacity(0.12))
                                .frame(width: 28, height: 28)

                            Image(systemName: item.iconName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(categoryColor(for: item.iconColorCategory))
                        }

                        // Title & Details
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.categoryDetails)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        // Amount & Chevron
                        Text(item.amount)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if index < approvals.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }

    private func categoryColor(for name: String) -> Color {
        switch name.lowercased() {
        case "purple": return .purple
        case "red": return .red
        case "green": return .green
        default: return .blue
        }
    }
}

// MARK: - 5. Top Customers List

struct TopCustomersListView: View {
    let customers: [TopCustomer]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Top Customers")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("By Billed Volume")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(customers.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        // Number Circle
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 22, height: 22)

                            Text("\(item.rank)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.secondary)
                        }

                        // Name & Category
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.subtitle)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        // Revenue
                        Text(item.revenue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if index < customers.count - 1 {
                        Divider()
                            .padding(.leading, 46)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - 6. Dealer Performance List

struct DealerPerformanceListView: View {
    let dealers: [DealerPerformanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Dealer Performance")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Q3 Quota")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(dealers.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.volumeSubtitle)
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(item.targetPercentage)%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(item.targetPercentage >= 80 ? Color.green : Color.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background((item.targetPercentage >= 80 ? Color.green : Color.orange).opacity(0.12))
                                .clipShape(Capsule())

                            Text(item.ordersCountText)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)

                    if index < dealers.count - 1 {
                        Divider()
                            .padding(.leading, 12)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
        }
    }
}
