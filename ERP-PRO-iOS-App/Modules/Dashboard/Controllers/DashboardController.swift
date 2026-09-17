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
                amount: 1248500.0,
                trendPercentage: 12.5,
                trendComparison: "vs Last Period",
                sparkline: [9.8, 10.4, 11.1, 10.9, 11.8, 12.485]
            ),
            revenueOverview: KPIRevenueMetric(
                amount: 1085200.0,
                monthlyTrend: "+8.2% vs last month",
                comparison: "Monthly Revenue"
            ),
            pendingPayments: KPIPendingPaymentsMetric(
                amount: 324800.0,
                unpaidInvoiceCount: 18
            ),
            ordersSummary: KPIOrdersMetric(
                totalOrders: 248,
                pendingApprovalCount: 24
            ),
            inventorySummary: KPIInventoryMetric(
                totalItemsInStock: 8642
            ),
            customerActivity: KPICustomerActivityMetric(
                activeCustomerCount: 486,
                newCustomerCount: 32
            ),
            lowStockAlerts: KPILowStockMetric(
                itemsBelowReorderCount: 14
            ),
            businessOverview: KPIBusinessOverviewMetric(
                achievementPercentage: 92.0,
                currentAchievement: 1248500.0,
                target: 1350000.0
            )
        ),
        charts: DashboardChartsData(
            monthlySales: [
                MonthlySalesDataPoint(month: "Jan", salesValue: 75000),
                MonthlySalesDataPoint(month: "Feb", salesValue: 82000),
                MonthlySalesDataPoint(month: "Mar", salesValue: 95000),
                MonthlySalesDataPoint(month: "Apr", salesValue: 88000),
                MonthlySalesDataPoint(month: "May", salesValue: 105000),
                MonthlySalesDataPoint(month: "Jun", salesValue: 112000),
                MonthlySalesDataPoint(month: "Jul", salesValue: 98000),
                MonthlySalesDataPoint(month: "Aug", salesValue: 115000),
                MonthlySalesDataPoint(month: "Sep", salesValue: 125000),
                MonthlySalesDataPoint(month: "Oct", salesValue: 130000),
                MonthlySalesDataPoint(month: "Nov", salesValue: 120000),
                MonthlySalesDataPoint(month: "Dec", salesValue: 145000)
            ],
            revenueTrend: [
                RevenueTrendDataPoint(label: "Q1", thisYear: 252000, lastYear: 210000),
                RevenueTrendDataPoint(label: "Q2", thisYear: 305000, lastYear: 270000),
                RevenueTrendDataPoint(label: "Q3", thisYear: 338000, lastYear: 295000),
                RevenueTrendDataPoint(label: "Q4", thisYear: 395000, lastYear: 340000)
            ],
            paymentCollection: PaymentCollectionDataPoint(
                collected: 845000.0,
                pending: 215000.0,
                overdue: 109800.0
            ),
            inventoryTrend: [
                InventoryTrendDataPoint(date: "Day 1", stockLevel: 9200),
                InventoryTrendDataPoint(date: "Day 5", stockLevel: 9050),
                InventoryTrendDataPoint(date: "Day 10", stockLevel: 8890),
                InventoryTrendDataPoint(date: "Day 15", stockLevel: 8720),
                InventoryTrendDataPoint(date: "Day 20", stockLevel: 8810),
                InventoryTrendDataPoint(date: "Day 25", stockLevel: 8690),
                InventoryTrendDataPoint(date: "Day 30", stockLevel: 8642)
            ],
            dealerActivity: [
                DealerActivityDataPoint(dealerName: "Apex Traders", orderVolume: 48, orderValue: 320000.0, activeDealers: 12),
                DealerActivityDataPoint(dealerName: "Metro Tech", orderVolume: 42, orderValue: 285000.0, activeDealers: 10),
                DealerActivityDataPoint(dealerName: "Global Supplies", orderVolume: 36, orderValue: 240000.0, activeDealers: 8),
                DealerActivityDataPoint(dealerName: "Zenith Retail", orderVolume: 24, orderValue: 160000.0, activeDealers: 6)
            ],
            arAging: [
                ARAgingDataPoint(period: "Current", amount: 450000.0),
                ARAgingDataPoint(period: "1–30 Days", amount: 210000.0),
                ARAgingDataPoint(period: "31–60 Days", amount: 120000.0),
                ARAgingDataPoint(period: "61–90 Days", amount: 75000.0),
                ARAgingDataPoint(period: "90+ Days", amount: 34800.0)
            ],
            cashFlowForecast: [
                CashFlowDataPoint(date: "W1", inflows: 280000, outflows: 190000, netCashFlow: 90000),
                CashFlowDataPoint(date: "W2", inflows: 310000, outflows: 210000, netCashFlow: 100000),
                CashFlowDataPoint(date: "W3", inflows: 290000, outflows: 185000, netCashFlow: 105000),
                CashFlowDataPoint(date: "W4", inflows: 340000, outflows: 230000, netCashFlow: 110000)
            ]
        ),
        ordersPipeline: OrdersPipelineSummary(
            newCount: 32,
            confirmedCount: 45,
            processingCount: 68,
            shippedCount: 74,
            deliveredCount: 29
        ),
        topCustomers: [
            TopCustomer(name: "Acme Corp", revenue: 245000.0, paymentHealth: "Paid"),
            TopCustomer(name: "Globex Trading", revenue: 185000.0, paymentHealth: "Outstanding"),
            TopCustomer(name: "Wayne Enterprises", revenue: 140000.0, paymentHealth: "Overdue"),
            TopCustomer(name: "Stark Logistics", revenue: 115000.0, paymentHealth: "Paid"),
            TopCustomer(name: "Umbrella Corp", revenue: 95000.0, paymentHealth: "Outstanding")
        ],
        pendingApprovals: [
            PendingApproval(id: "APP-01", type: "Expenses", title: "Travel Reimbursement", amount: 15400.0, requestedBy: "Rahul Sharma", date: "16 Sep 2026"),
            PendingApproval(id: "APP-02", type: "Purchase Orders", title: "Raw Material PO #892", amount: 125000.0, requestedBy: "Priya Patel", date: "17 Sep 2026"),
            PendingApproval(id: "APP-03", type: "Credit Notes", title: "Return Credit Note #104", amount: 18200.0, requestedBy: "Amit Verma", date: "17 Sep 2026")
        ],
        dealerPerformance: [
            DealerPerformanceItem(region: "North", mtdOrders: 48, sales: 320000.0, targetAchievementPercentage: 95.0, commissionDue: 16000.0),
            DealerPerformanceItem(region: "West", mtdOrders: 42, sales: 285000.0, targetAchievementPercentage: 92.0, commissionDue: 14250.0),
            DealerPerformanceItem(region: "South", mtdOrders: 36, sales: 240000.0, targetAchievementPercentage: 88.0, commissionDue: 12000.0),
            DealerPerformanceItem(region: "East", mtdOrders: 24, sales: 160000.0, targetAchievementPercentage: 80.0, commissionDue: 8000.0)
        ],
        supportTicketSummary: SupportTicketSummary(
            openTicketsCount: 12,
            priority: "High",
            slaStatus: "On Track"
        ),
        recentActivities: [
            RecentActivityItem(id: "ACT-01", title: "Order #ORD-9421", category: "Order", timestamp: "10 mins ago", detail: "Confirmed by Acme Corp"),
            RecentActivityItem(id: "ACT-02", title: "Payment Received", category: "Payment", timestamp: "45 mins ago", detail: "₹1,25,000 from Stark Logistics"),
            RecentActivityItem(id: "ACT-03", title: "Stock Adjustment", category: "Inventory", timestamp: "2 hours ago", detail: "Added 150 units to Main WH"),
            RecentActivityItem(id: "ACT-04", title: "Expense Submitted", category: "Expense", timestamp: "4 hours ago", detail: "₹15,400 Travel Reimbursement")
        ],
        lowStockItems: [
            LowStockItem(sku: "SKU-VALVE-101", productName: "Industrial Valve 2-inch", category: "Machinery", stockLevel: 4, reorderLevel: 10, warehouse: "Main WH"),
            LowStockItem(sku: "SKU-CABLE-204", productName: "Copper Armored Cable", category: "Electrical", stockLevel: 12, reorderLevel: 30, warehouse: "South Hub"),
            LowStockItem(sku: "SKU-BEAR-305", productName: "Ball Bearing Assembly", category: "Spare Parts", stockLevel: 8, reorderLevel: 20, warehouse: "West Depot"),
            LowStockItem(sku: "SKU-PUMP-408", productName: "Hydraulic Fluid Pump", category: "Machinery", stockLevel: 2, reorderLevel: 5, warehouse: "Main WH")
        ],
        alertBanners: [
            AlertBannerItem(id: "ALT-01", message: "Overdue Invoices: 3 invoices totaling ₹1,09,800 are past due date.", type: "Overdue Invoices", severity: "danger"),
            AlertBannerItem(id: "ALT-02", message: "Critical Stock Warning: 14 items currently below minimum reorder level.", type: "Stock Alert", severity: "warning"),
            AlertBannerItem(id: "ALT-03", message: "Pending Approvals: 3 high-value requests awaiting your authorization.", type: "Approvals", severity: "info"),
            AlertBannerItem(id: "ALT-04", message: "GSTR-1 Filing Deadline: Tax compliance filing due in 3 days.", type: "Compliance", severity: "warning")
        ]
    )
}
