//
//  DashboardModel.swift
//  ERP-PRO-iOS-App
//

import Foundation

/// Root backend response container for the Dashboard API endpoint (/api/v1/dashboard).
public struct DashboardResponse: Codable, Sendable {
    public let success: Bool?
    public let message: String?
    public let data: DashboardData?
    
    public init(success: Bool? = true, message: String? = nil, data: DashboardData?) {
        self.success = success
        self.message = message
        self.data = data
    }
}

/// Root data model representing the backend Dashboard state.
public struct DashboardData: Codable, Sendable {
    public let kpis: DashboardKPIMetrics?
    public let performanceMetrics: [PerformanceMetricRow]?
    public let ordersPipeline: OrdersPipelineSummary?
    public let paymentCollection: PaymentCollectionSummary?
    public let topCustomers: [TopCustomer]?
    public let pendingApprovals: [PendingApproval]?
    public let dealerPerformance: [DealerPerformanceItem]?
    public let alertBanners: [AlertBannerItem]?
    
    public init(
        kpis: DashboardKPIMetrics?,
        performanceMetrics: [PerformanceMetricRow]? = nil,
        ordersPipeline: OrdersPipelineSummary?,
        paymentCollection: PaymentCollectionSummary? = nil,
        topCustomers: [TopCustomer]?,
        pendingApprovals: [PendingApproval]?,
        dealerPerformance: [DealerPerformanceItem]?,
        alertBanners: [AlertBannerItem]?
    ) {
        self.kpis = kpis
        self.performanceMetrics = performanceMetrics
        self.ordersPipeline = ordersPipeline
        self.paymentCollection = paymentCollection
        self.topCustomers = topCustomers
        self.pendingApprovals = pendingApprovals
        self.dealerPerformance = dealerPerformance
        self.alertBanners = alertBanners
    }
}

// MARK: - KPI Metrics Models

public struct DashboardKPIMetrics: Codable, Sendable {
    public let totalSales: KPISalesMetric?
    public let revenueOverview: KPIRevenueMetric?
    public let pendingPayments: KPIPendingPaymentsMetric?
    public let ordersSummary: KPIOrdersMetric?
}

public struct KPISalesMetric: Codable, Sendable {
    public let formattedAmount: String
    public let trendText: String
    public let isPositiveTrend: Bool
    
    public init(formattedAmount: String, trendText: String, isPositiveTrend: Bool = true) {
        self.formattedAmount = formattedAmount
        self.trendText = trendText
        self.isPositiveTrend = isPositiveTrend
    }
}

public struct KPIRevenueMetric: Codable, Sendable {
    public let formattedAmount: String
    public let trendText: String
    public let isPositiveTrend: Bool
    
    public init(formattedAmount: String, trendText: String, isPositiveTrend: Bool = true) {
        self.formattedAmount = formattedAmount
        self.trendText = trendText
        self.isPositiveTrend = isPositiveTrend
    }
}

public struct KPIPendingPaymentsMetric: Codable, Sendable {
    public let formattedAmount: String
    public let invoiceBadge: String
    public let trendText: String
    public let isPositiveTrend: Bool
    
    public init(formattedAmount: String, invoiceBadge: String, trendText: String, isPositiveTrend: Bool = true) {
        self.formattedAmount = formattedAmount
        self.invoiceBadge = invoiceBadge
        self.trendText = trendText
        self.isPositiveTrend = isPositiveTrend
    }
}

public struct KPIOrdersMetric: Codable, Sendable {
    public let countText: String
    public let pendingBadge: String
    public let targetBadge: String
    
    public init(countText: String, pendingBadge: String, targetBadge: String) {
        self.countText = countText
        self.pendingBadge = pendingBadge
        self.targetBadge = targetBadge
    }
}

// MARK: - Performance Models

public struct PerformanceMetricRow: Codable, Identifiable, Sendable {
    public var id: String { title }
    public let title: String
    public let value: String
    public let trend: String
    
    public init(title: String, value: String, trend: String) {
        self.title = title
        self.value = value
        self.trend = trend
    }
}

// MARK: - Operations & Lists Models

public struct OrdersPipelineSummary: Codable, Sendable {
    public let newCount: Int
    public let newValue: String
    public let confirmedCount: Int
    public let confirmedValue: String
    public let processingCount: Int
    public let processingValue: String
    public let shippedCount: Int
    public let shippedValue: String
    public let deliveredCount: Int
    public let deliveredValue: String
    
    public init(
        newCount: Int, newValue: String,
        confirmedCount: Int, confirmedValue: String,
        processingCount: Int, processingValue: String,
        shippedCount: Int, shippedValue: String,
        deliveredCount: Int, deliveredValue: String
    ) {
        self.newCount = newCount
        self.newValue = newValue
        self.confirmedCount = confirmedCount
        self.confirmedValue = confirmedValue
        self.processingCount = processingCount
        self.processingValue = processingValue
        self.shippedCount = shippedCount
        self.shippedValue = shippedValue
        self.deliveredCount = deliveredCount
        self.deliveredValue = deliveredValue
    }
}

public struct PaymentCollectionSummary: Codable, Sendable {
    public let collectedPercentage: Double
    public let totalInvoiced: String
    public let statusBadge: String
    public let collectedAmount: String
    public let pendingAmount: String
    public let overdueAmount: String
    
    public init(
        collectedPercentage: Double,
        totalInvoiced: String,
        statusBadge: String,
        collectedAmount: String,
        pendingAmount: String,
        overdueAmount: String
    ) {
        self.collectedPercentage = collectedPercentage
        self.totalInvoiced = totalInvoiced
        self.statusBadge = statusBadge
        self.collectedAmount = collectedAmount
        self.pendingAmount = pendingAmount
        self.overdueAmount = overdueAmount
    }
}

public struct TopCustomer: Codable, Identifiable, Sendable {
    public var id: String { name }
    public let rank: Int
    public let name: String
    public let subtitle: String
    public let revenue: String
    public let paymentHealth: String // e.g. "Paid", "Outstanding", "Overdue"
    
    public init(rank: Int, name: String, subtitle: String, revenue: String, paymentHealth: String) {
        self.rank = rank
        self.name = name
        self.subtitle = subtitle
        self.revenue = revenue
        self.paymentHealth = paymentHealth
    }
}

public struct PendingApproval: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let categoryDetails: String
    public let amount: String
    public let iconName: String
    public let iconColorCategory: String // "purple", "blue", "red", "green"
    
    public init(id: String, title: String, categoryDetails: String, amount: String, iconName: String, iconColorCategory: String) {
        self.id = id
        self.title = title
        self.categoryDetails = categoryDetails
        self.amount = amount
        self.iconName = iconName
        self.iconColorCategory = iconColorCategory
    }
}

public struct DealerPerformanceItem: Codable, Identifiable, Sendable {
    public var id: String { name }
    public let name: String
    public let volumeSubtitle: String
    public let targetPercentage: Int
    public let ordersCountText: String
    
    public init(name: String, volumeSubtitle: String, targetPercentage: Int, ordersCountText: String) {
        self.name = name
        self.volumeSubtitle = volumeSubtitle
        self.targetPercentage = targetPercentage
        self.ordersCountText = ordersCountText
    }
}

public struct AlertBannerItem: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let severity: String // "danger", "purple", "info"
    public let iconName: String
    
    public init(id: String, title: String, subtitle: String, severity: String, iconName: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.severity = severity
        self.iconName = iconName
    }
}
