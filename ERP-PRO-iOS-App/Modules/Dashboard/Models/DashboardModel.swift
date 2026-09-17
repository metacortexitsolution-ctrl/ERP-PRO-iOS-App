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
    public let charts: DashboardChartsData?
    public let ordersPipeline: OrdersPipelineSummary?
    public let topCustomers: [TopCustomer]?
    public let pendingApprovals: [PendingApproval]?
    public let dealerPerformance: [DealerPerformanceItem]?
    public let supportTicketSummary: SupportTicketSummary?
    public let recentActivities: [RecentActivityItem]?
    public let lowStockItems: [LowStockItem]?
    public let alertBanners: [AlertBannerItem]?
    
    public init(
        kpis: DashboardKPIMetrics?,
        charts: DashboardChartsData?,
        ordersPipeline: OrdersPipelineSummary?,
        topCustomers: [TopCustomer]?,
        pendingApprovals: [PendingApproval]?,
        dealerPerformance: [DealerPerformanceItem]?,
        supportTicketSummary: SupportTicketSummary?,
        recentActivities: [RecentActivityItem]?,
        lowStockItems: [LowStockItem]?,
        alertBanners: [AlertBannerItem]?
    ) {
        self.kpis = kpis
        self.charts = charts
        self.ordersPipeline = ordersPipeline
        self.topCustomers = topCustomers
        self.pendingApprovals = pendingApprovals
        self.dealerPerformance = dealerPerformance
        self.supportTicketSummary = supportTicketSummary
        self.recentActivities = recentActivities
        self.lowStockItems = lowStockItems
        self.alertBanners = alertBanners
    }
}

// MARK: - KPI Metrics Models

public struct DashboardKPIMetrics: Codable, Sendable {
    public let totalSales: KPISalesMetric?
    public let revenueOverview: KPIRevenueMetric?
    public let pendingPayments: KPIPendingPaymentsMetric?
    public let ordersSummary: KPIOrdersMetric?
    public let inventorySummary: KPIInventoryMetric?
    public let customerActivity: KPICustomerActivityMetric?
    public let lowStockAlerts: KPILowStockMetric?
    public let businessOverview: KPIBusinessOverviewMetric?
}

public struct KPISalesMetric: Codable, Sendable {
    public let amount: Double
    public let trendPercentage: Double?
    public let trendComparison: String?
    public let sparkline: [Double]?
}

public struct KPIRevenueMetric: Codable, Sendable {
    public let amount: Double
    public let monthlyTrend: String?
    public let comparison: String?
}

public struct KPIPendingPaymentsMetric: Codable, Sendable {
    public let amount: Double
    public let unpaidInvoiceCount: Int
}

public struct KPIOrdersMetric: Codable, Sendable {
    public let totalOrders: Int
    public let pendingApprovalCount: Int
}

public struct KPIInventoryMetric: Codable, Sendable {
    public let totalItemsInStock: Int
}

public struct KPICustomerActivityMetric: Codable, Sendable {
    public let activeCustomerCount: Int
    public let newCustomerCount: Int
}

public struct KPILowStockMetric: Codable, Sendable {
    public let itemsBelowReorderCount: Int
}

public struct KPIBusinessOverviewMetric: Codable, Sendable {
    public let achievementPercentage: Double
    public let currentAchievement: Double
    public let target: Double
}

// MARK: - Charts Models

public struct DashboardChartsData: Codable, Sendable {
    public let monthlySales: [MonthlySalesDataPoint]?
    public let revenueTrend: [RevenueTrendDataPoint]?
    public let paymentCollection: PaymentCollectionDataPoint?
    public let inventoryTrend: [InventoryTrendDataPoint]?
    public let dealerActivity: [DealerActivityDataPoint]?
    public let arAging: [ARAgingDataPoint]?
    public let cashFlowForecast: [CashFlowDataPoint]?
}

public struct MonthlySalesDataPoint: Codable, Identifiable, Sendable {
    public var id: String { month }
    public let month: String
    public let salesValue: Double
}

public struct RevenueTrendDataPoint: Codable, Identifiable, Sendable {
    public var id: String { label }
    public let label: String
    public let thisYear: Double
    public let lastYear: Double
}

public struct PaymentCollectionDataPoint: Codable, Sendable {
    public let collected: Double
    public let pending: Double
    public let overdue: Double
}

public struct InventoryTrendDataPoint: Codable, Identifiable, Sendable {
    public var id: String { date }
    public let date: String
    public let stockLevel: Int
}

public struct DealerActivityDataPoint: Codable, Identifiable, Sendable {
    public var id: String { dealerName }
    public let dealerName: String
    public let orderVolume: Int
    public let orderValue: Double
    public let activeDealers: Int?
}

public struct ARAgingDataPoint: Codable, Identifiable, Sendable {
    public var id: String { period }
    public let period: String
    public let amount: Double
}

public struct CashFlowDataPoint: Codable, Identifiable, Sendable {
    public var id: String { date }
    public let date: String
    public let inflows: Double
    public let outflows: Double
    public let netCashFlow: Double
}

// MARK: - Operations & Lists Models

public struct OrdersPipelineSummary: Codable, Sendable {
    public let newCount: Int
    public let confirmedCount: Int
    public let processingCount: Int
    public let shippedCount: Int
    public let deliveredCount: Int
}

public struct TopCustomer: Codable, Identifiable, Sendable {
    public var id: String { name }
    public let name: String
    public let revenue: Double
    public let paymentHealth: String // e.g. "Paid", "Outstanding", "Overdue"
}

public struct PendingApproval: Codable, Identifiable, Sendable {
    public let id: String
    public let type: String // e.g. "Expenses", "Purchase Orders", "Credit Notes"
    public let title: String
    public let amount: Double
    public let requestedBy: String
    public let date: String
}

public struct DealerPerformanceItem: Codable, Identifiable, Sendable {
    public var id: String { region }
    public let region: String
    public let mtdOrders: Int
    public let sales: Double
    public let targetAchievementPercentage: Double
    public let commissionDue: Double
}

public struct SupportTicketSummary: Codable, Sendable {
    public let openTicketsCount: Int
    public let priority: String
    public let slaStatus: String // e.g. "On Track", "At Risk", "Breached"
}

public struct RecentActivityItem: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let timestamp: String
    public let detail: String
}

public struct LowStockItem: Codable, Identifiable, Sendable {
    public var id: String { sku }
    public let sku: String
    public let productName: String
    public let category: String
    public let stockLevel: Int
    public let reorderLevel: Int
    public let warehouse: String
}

public struct AlertBannerItem: Codable, Identifiable, Sendable {
    public let id: String
    public let message: String
    public let type: String
    public let severity: String
}
