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
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Performance")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Text("Year over Year")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(metrics.enumerated()), id: \.element.id) { index, row in
                    HStack(spacing: 12) {
                        Text(row.title)
                            .font(.system(size: DeviceInfo.isPad ? 15 : 14, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        Text(row.value)
                            .font(.system(size: DeviceInfo.isPad ? 16 : 15, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(row.trend)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.05, green: 0.65, blue: 0.3))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, DeviceInfo.isPad ? 16 : 14)
                    .frame(height: DeviceInfo.isPad ? 45 : 44)

                    if index < metrics.count - 1 {
                        Divider()
                            .padding(.leading, DeviceInfo.isPad ? 16 : 14)
                    }
                }
            }
            .frame(minHeight: DeviceInfo.isPad ? 275 : 0)
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

// MARK: - 2. Sales Orders Pipeline

struct SalesOrdersPipelineView: View {
    let pipeline: OrdersPipelineSummary

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Sales Orders")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Button("View all →") {}
                    .font(.system(size: 13, weight: .semibold))
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
            .padding(.horizontal, DeviceInfo.isPad ? 16 : 14)
            .padding(.vertical, 14)
            .frame(height: DeviceInfo.isPad ? 105 : 132)
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

struct PipelineStageItem: View {
    let stage: String
    let count: Int
    let value: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Top Blue Bar
            Rectangle()
                .fill(isCompleted ? Color.blue : Color.blue.opacity(0.25))
                .frame(height: 4)
                .cornerRadius(2)

            Text(stage)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text("\(count)")
                .font(.system(size: DeviceInfo.isPad ? 19 : 18, weight: .semibold))
                .foregroundColor(.primary)

            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 3. Payment Collection

struct PaymentCollectionView: View {
    let payment: PaymentCollectionSummary

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Payment Collection")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Text(payment.totalInvoiced)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 14) {
                // Main Stat & Health Badge
                HStack(alignment: .firstTextBaseline) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(String(format: "%.2f%%", payment.collectedPercentage))
                            .font(CommonFont.kpiHeroValue)
                            .foregroundColor(.primary)

                        Text("collected")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text(payment.statusBadge)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.05, green: 0.65, blue: 0.3))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                }

                // Multi-segment progress bar (Height: 8px, Capsule rounded ends)
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
                .frame(height: 8)
                .clipShape(Capsule())

                // 3 Financial States Evenly Distributed
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.blue).frame(width: 8, height: 8)
                            Text("Collected")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.collectedAmount)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.purple).frame(width: 8, height: 8)
                            Text("Pending")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.pendingAmount)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("Overdue")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        Text(payment.overdueAmount)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color.red)
                    }
                }
            }
            .padding(.horizontal, DeviceInfo.isPad ? 18 : 14)
            .padding(.vertical, 16)
            .frame(height: DeviceInfo.isPad ? 150 : 190)
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

// MARK: - 4. Pending Approvals List

struct PendingApprovalsListView: View {
    let approvals: [PendingApproval]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Pending Approvals")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Button("View all (\(approvals.count)) →") {}
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.blue)
            }

            VStack(spacing: 0) {
                ForEach(Array(approvals.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        // Tinted Icon Circle
                        ZStack {
                            Circle()
                                .fill(categoryColor(for: item.iconColorCategory).opacity(0.12))
                                .frame(width: 32, height: 32)

                            Image(systemName: item.iconName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(categoryColor(for: item.iconColorCategory))
                        }

                        // Title & Details
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.categoryDetails)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)

                        // Amount & Chevron
                        Text(item.amount)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.horizontal, DeviceInfo.isPad ? 16 : 14)
                    .frame(height: DeviceInfo.isPad ? 64 : 74)

                    if index < approvals.count - 1 {
                        Divider()
                            .padding(.leading, 58)
                    }
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
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Top Customers")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Text("By Billed Volume")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(customers.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        // Rank Circle (30–32px)
                        ZStack {
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .frame(width: 30, height: 30)

                            Text("\(item.rank)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.secondary)
                        }

                        // Name & Category
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.subtitle)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)

                        // Revenue
                        Text(item.revenue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, DeviceInfo.isPad ? 16 : 14)
                    .frame(height: 66)

                    if index < customers.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
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

// MARK: - 6. Dealer Performance List

struct DealerPerformanceListView: View {
    let dealers: [DealerPerformanceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: CommonSpacing.headingToCardSpacing) {
            HStack {
                Text("Dealer Performance")
                    .font(CommonFont.sectionHeading)
                    .foregroundColor(.primary)
                Spacer()
                Text("Q3 Quota")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(dealers.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)

                            Text(item.volumeSubtitle)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.secondary)
                        }

                        Spacer(minLength: 8)

                        VStack(alignment: .trailing, spacing: 3) {
                            Text("\(item.targetPercentage)%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(item.targetPercentage >= 80 ? Color(red: 0.05, green: 0.65, blue: 0.3) : Color.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background((item.targetPercentage >= 80 ? Color.green : Color.orange).opacity(0.12))
                                .clipShape(Capsule())

                            Text(item.ordersCountText)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, DeviceInfo.isPad ? 16 : 14)
                    .frame(height: 72)

                    if index < dealers.count - 1 {
                        Divider()
                            .padding(.leading, DeviceInfo.isPad ? 16 : 14)
                    }
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
