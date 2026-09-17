//
//  ConstantString.swift
//  ERP-PRO-iOS-App
//

import Foundation

public struct ConstantString {
    // MARK: - Navigation Tabs
    public static let dashboard = "Home"
    public static let home = "Home"
    public static let invoice = "Invoice"
    public static let payment = "Payment"
    public static let more = "More"
    public static let settings = "Settings"
    
    // MARK: - Dashboard Sections & Headers
    public static let kpiOverview = "KPI Overview"
    public static let alertBanners = "Alert Banners"
    public static let salesRevenueAnalytics = "Sales & Revenue Analytics"
    public static let paymentCollection = "Payment Collection"
    public static let ordersPipeline = "Orders Pipeline"
    public static let inventorySummary = "Inventory Summary"
    public static let arAging = "AR Aging"
    public static let cashFlowForecast = "Cash Flow Forecast"
    public static let topCustomers = "Top Customers"
    public static let pendingApprovals = "Pending Approvals"
    public static let dealerPerformance = "Dealer Performance"
    public static let supportTicketSummary = "Support Ticket Summary"
    public static let recentActivity = "Recent Activity"
    public static let lowStockTable = "Low Stock Table"
    
    // MARK: - KPI Cards
    public static let totalSales = "Total Sales"
    public static let revenueOverview = "Revenue Overview"
    public static let pendingPayments = "Pending Payments"
    public static let ordersSummary = "Orders Summary"
    public static let customerActivity = "Customer Activity"
    public static let lowStockAlerts = "Low Stock Alerts"
    public static let businessOverview = "Business Overview"
    
    // MARK: - Metrics & Subtitles
    public static let activeCustomers = "Active Customers"
    public static let newCustomers = "New Customers"
    public static let pendingApprovalOrders = "Pending Approval"
    public static let totalInStock = "Total in Stock"
    public static let unpaidInvoices = "Unpaid Invoices"
    public static let itemsBelowReorder = "Items Below Reorder"
    public static let achievementTarget = "Achievement Target"
    public static let vsLastPeriod = "vs Last Period"
    
    // MARK: - Charts & Legend Labels
    public static let monthlySalesChart = "Monthly Sales"
    public static let revenueTrend = "Revenue Trend"
    public static let inventoryTrend = "Inventory Trend"
    public static let dealerActivity = "Dealer Activity"
    public static let thisYear = "This Year"
    public static let lastYear = "Last Year"
    public static let collected = "Collected"
    public static let pending = "Pending"
    public static let overdue = "Overdue"
    public static let inflows = "Inflows"
    public static let outflows = "Outflows"
    public static let netCashFlow = "Net Cash Flow"
    public static let orderVolume = "Order Volume"
    public static let orderValue = "Order Value"
    
    // MARK: - AR Aging Periods
    public static let agingCurrent = "Current"
    public static let aging1to30 = "1–30 Days"
    public static let aging31to60 = "31–60 Days"
    public static let aging61to90 = "61–90 Days"
    public static let aging90Plus = "90+ Days"
    
    // MARK: - Status Badges
    public static let paid = "Paid"
    public static let outstanding = "Outstanding"
    public static let onTrack = "On Track"
    public static let atRisk = "At Risk"
    public static let breached = "Breached"
    
    // MARK: - Pipeline Stages
    public static let pipelineNew = "New"
    public static let pipelineConfirmed = "Confirmed"
    public static let pipelineProcessing = "Processing"
    public static let pipelineShipped = "Shipped"
    public static let pipelineDelivered = "Delivered"
    
    // MARK: - Approvals & Categories
    public static let expenses = "Expenses"
    public static let purchaseOrders = "Purchase Orders"
    public static let creditNotes = "Credit Notes"
    
    // MARK: - Table Headers
    public static let sku = "SKU"
    public static let productName = "Product Name"
    public static let category = "Category"
    public static let stockLevel = "Stock Level"
    public static let reorderLevel = "Reorder Level"
    public static let warehouse = "Warehouse"
    public static let customerName = "Customer Name"
    public static let revenue = "Revenue"
    public static let paymentHealth = "Payment Health"
    public static let region = "Region"
    public static let mtdOrders = "MTD Orders"
    public static let sales = "Sales"
    public static let targetAchievement = "Target %"
    public static let commissionDue = "Commission Due"
    
    // MARK: - UI States & Common Buttons
    public static let loadingDashboard = "Loading Home..."
    public static let emptyTitle = "No Home Data"
    public static let emptyMessage = "No data is currently available for your account."
    public static let errorTitle = "Unable to Load Home"
    public static let retry = "Retry"
    public static let refresh = "Refresh"
    public static let lastUpdated = "Last updated"
    
    // MARK: - Placeholders & Modules
    public static let invoiceModulePlaceholder = "Invoice Module Navigation Stack"
    public static let paymentModulePlaceholder = "Payment Module Navigation Stack"
    public static let settingsModulePlaceholder = "Settings Module Navigation Stack"
    public static let moreModulesTitle = "ERP Modules"
    
    // MARK: - Header Profile & Company Menus
    public static let myProfile = "My Profile"
    public static let notificationPreferences = "Notification Preferences"
    public static let theme = "Theme"
    public static let systemSettings = "System Settings"
    public static let logOut = "Log Out"
    public static let switchCompany = "Switch Company"
}
