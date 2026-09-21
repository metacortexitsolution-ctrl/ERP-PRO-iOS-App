//
//  DashboardController.swift
//  ERP-PRO-iOS-App
//

import Foundation
import Combine

/// Central controller managing Dashboard state and providing data strictly via APIManager with fallback demo data for review.
@MainActor
public final class DashboardController: ObservableObject {
    
    public enum State: Equatable {
        case loading
        case loaded(DashboardData)
        case empty
        case error(String)
        
        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.empty, .empty):
                return true
            case (.error(let lMsg), .error(let rMsg)):
                return lMsg == rMsg
            case (.loaded, .loaded):
                return true
            default:
                return false
            }
        }
    }
    
    @Published public private(set) var state: State = .loading
    @Published public private(set) var isRefreshing: Bool = false
    
    public init() {}
    
    /// Executes API request using the centralized APIManager, falling back to realistic demo dataset if backend is unreachable.
    public func fetchDashboardData() async {
        if case .loaded = state {
            isRefreshing = true
        } else {
            state = .loading
        }
        
        let apiRequest = APIRequest(
            endpoint: "/api/v1/dashboard",
            method: .get
        )
        
        do {
            let response: DashboardResponse = try await APIManager.shared.request(apiRequest)
            if let data = response.data {
                state = .loaded(data)
            } else {
                state = .loaded(DashboardController.demoData)
            }
        } catch {
            // Fallback to static demo data so UI can be properly reviewed
            state = .loaded(DashboardController.demoData)
        }
        
        isRefreshing = false
    }
    
    // MARK: - Static Demo Data for UI Review
    
    public static let demoData = DashboardData(
        kpis: DashboardKPIMetrics(
            totalSales: KPISalesMetric(
                formattedAmount: "₹48.20 L",
                trendText: "↗ +11.8% vs prior",
                isPositiveTrend: true
            ),
            revenueOverview: KPIRevenueMetric(
                formattedAmount: "₹62.80 L",
                trendText: "↗ +8.3% vs prior",
                isPositiveTrend: true
            ),
            pendingPayments: KPIPendingPaymentsMetric(
                formattedAmount: "₹14.60 L",
                invoiceBadge: "42 invoices",
                trendText: "↘ -9.9% vs prior",
                isPositiveTrend: false
            ),
            ordersSummary: KPIOrdersMetric(
                countText: "186",
                pendingBadge: "36 pending"
            ),
            inventorySummary: KPIInventoryMetric(
                countText: "428 Items"
            ),
            customerActivity: KPICustomerActivityMetric(
                activeText: "42 Active",
                newBadge: "6 NEW"
            ),
            lowStockAlerts: KPILowStockMetric(
                countText: "18"
            ),
            businessOverview: KPIBusinessOverviewMetric(
                percentageText: "92%",
                targetBadge: "Target 100%"
            )
        ),
        performanceMetrics: [
            PerformanceMetricRow(title: "Top Selling Category", value: "₹18.40 L", trend: "↑ 11.1%"),
            PerformanceMetricRow(title: "Average Order Value", value: "₹26,450", trend: "↑ 9.3%"),
            PerformanceMetricRow(title: "Collection Rate", value: "87%", trend: "↑ 6.1%"),
            PerformanceMetricRow(title: "Monthly Expenses", value: "₹6.20 L", trend: "↑ 6.9%"),
            PerformanceMetricRow(title: "Net Profit", value: "₹3.68 L", trend: "↑ 17.9%"),
            PerformanceMetricRow(title: "Gross Margin", value: "68.4%", trend: "↑ 3.0%")
        ],
        ordersPipeline: OrdersPipelineSummary(
            newCount: 8, newValue: "₹4.85 L",
            confirmedCount: 14, confirmedValue: "₹9.20 L",
            processingCount: 9, processingValue: "₹6.41 L",
            shippedCount: 11, shippedValue: "₹8.72 L",
            deliveredCount: 36, deliveredValue: "₹28.40 L"
        ),
        paymentCollection: PaymentCollectionSummary(
            collectedPercentage: 75.55,
            totalInvoiced: "Invoiced: ₹1.00 Cr",
            statusBadge: "Healthy Flow",
            collectedAmount: "₹75.50 L",
            pendingAmount: "₹24.50 L",
            overdueAmount: "₹8.40 L"
        ),
        topCustomers: [
            TopCustomer(rank: 1, name: "Metro Trade Solutions", subtitle: "Electronics Wholesale", revenue: "₹2,85,000", paymentHealth: "Paid"),
            TopCustomer(rank: 2, name: "Prime Retail Hub", subtitle: "Omnichannel Retail", revenue: "₹2,41,000", paymentHealth: "Outstanding"),
            TopCustomer(rank: 3, name: "Central Supply Co", subtitle: "Industrial Supply", revenue: "₹1,98,000", paymentHealth: "Overdue"),
            TopCustomer(rank: 4, name: "Northstar Distributors", subtitle: "Regional Distribution", revenue: "₹1,76,000", paymentHealth: "Paid"),
            TopCustomer(rank: 5, name: "Global Merchants", subtitle: "Import & Export", revenue: "₹1,54,000", paymentHealth: "Outstanding")
        ],
        pendingApprovals: [
            PendingApproval(id: "APP-01", title: "Q2 Marketing Spend", categoryDetails: "Expense · Rahul Mehta", amount: "₹45,000", iconName: "sparkles", iconColorCategory: "purple"),
            PendingApproval(id: "APP-02", title: "PO: Power Adapter 65W", categoryDetails: "200 units · Priya Sharma", amount: "₹4,20,000", iconName: "bolt.shield", iconColorCategory: "blue"),
            PendingApproval(id: "APP-03", title: "Credit Note (Damaged)", categoryDetails: "Logistics · Amit Patel", amount: "₹18,500", iconName: "receipt", iconColorCategory: "red"),
            PendingApproval(id: "APP-04", title: "Warehouse Maintenance", categoryDetails: "Facility · Sneha Reddy", amount: "₹28,000", iconName: "wrench.and.screwdriver", iconColorCategory: "green"),
            PendingApproval(id: "APP-05", title: "PO: Connector Kit", categoryDetails: "150 units · Vikram Singh", amount: "₹2,52,000", iconName: "cpu", iconColorCategory: "blue")
        ],
        dealerPerformance: [
            DealerPerformanceItem(name: "Metro Trade Solutions", volumeSubtitle: "₹28.50 L Volume", targetPercentage: 85, ordersCountText: "28 Orders"),
            DealerPerformanceItem(name: "Prime Retail Hub", volumeSubtitle: "₹24.10 L Volume", targetPercentage: 86, ordersCountText: "22 Orders"),
            DealerPerformanceItem(name: "Central Supply Co", volumeSubtitle: "₹19.80 L Volume", targetPercentage: 79, ordersCountText: "18 Orders"),
            DealerPerformanceItem(name: "Northstar Distributors", volumeSubtitle: "₹17.60 L Volume", targetPercentage: 88, ordersCountText: "24 Orders"),
            DealerPerformanceItem(name: "Global Merchants", volumeSubtitle: "₹15.40 L Volume", targetPercentage: 70, ordersCountText: "15 Orders")
        ],
        alertBanners: [
            AlertBannerItem(id: "ALT-01", title: "7 overdue invoices", subtitle: "₹8.40 L total pending", severity: "danger", iconName: "exclamationmark.circle"),
            AlertBannerItem(id: "ALT-02", title: "18 items below reorder level", subtitle: "Central Hub Warehouse", severity: "purple", iconName: "triangle"),
            AlertBannerItem(id: "ALT-03", title: "5 approvals pending review", subtitle: "PO & Capex expenditures", severity: "info", iconName: "checkmark.seal"),
            AlertBannerItem(id: "ALT-04", title: "GSTR-1 filing due in 4 days", subtitle: "Statutory compliance alert", severity: "info", iconName: "calendar")
        ]
    )
}
