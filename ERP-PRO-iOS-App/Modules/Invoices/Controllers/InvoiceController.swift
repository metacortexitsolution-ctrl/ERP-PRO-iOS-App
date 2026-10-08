//
//  InvoiceController.swift
//  ERP-PRO-iOS-App
//

import Foundation
import Combine
import SwiftUI

public enum InvoiceSortField: String, CaseIterable, Identifiable {
    case date = "Date"
    case invoiceNumber = "Invoice #"
    case amount = "Amount"
    case customerName = "Customer"
    case dueDate = "Due Date"
    case status = "Status"

    public var id: String { rawValue }
}

public enum DateType: String, CaseIterable, Identifiable {
    case issueDate = "Issue Date"
    case dueDate = "Due Date"

    public var id: String { rawValue }
}

public enum FilterCategory: String, CaseIterable, Identifiable {
    case status = "Status"
    case dateRange = "Date Range"
    case currency = "Currency"
    case paymentStatus = "Payment Status"
    case amount = "Amount"
    case customer = "Customer"
    case salesperson = "Salesperson"
    case branch = "Branch"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .status: return "tag.fill"
        case .dateRange: return "calendar"
        case .currency: return "dollarsign.circle.fill"
        case .paymentStatus: return "creditcard.fill"
        case .amount: return "indianrupeesign.circle.fill"
        case .customer: return "person.2.fill"
        case .salesperson: return "person.badge.shield.checkmark.fill"
        case .branch: return "building.2.fill"
        }
    }
}

/// Central controller managing Accounts Receivable & Invoicing state, multi-platform views, filtering, metrics, and bulk operations.
@MainActor
public final class InvoiceController: ObservableObject {

    public enum State: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
    }

    @Published public private(set) var state: State = .loading
    @Published public var invoices: [Invoice] = []

    // Search & Filter Bar State
    @Published public var searchText: String = ""
    @Published public var selectedFilterChip: InvoiceFilterChip = .all
    @Published public var sortField: InvoiceSortField = .date
    @Published public var sortAscending: Bool = false

    // Selection & Column Customization State
    @Published public var isEditingMode: Bool = false
    @Published public var selectedInvoiceIDs: Set<String> = []
    @Published public var visibleOptionalColumns: Set<OptionalColumn> = [.salesperson, .currency, .poReference]
    @Published public var selectedInvoice: Invoice? = nil
    @Published public var isShowingNewInvoiceSheet: Bool = false
    @Published public var isShowingPDFPreview: Bool = false
    @Published public var isShowingThermalPrintSheet: Bool = false

    // Advanced Floating Filter Popover State & Single Active Submenu
    @Published public var isFilterPopoverPresented: Bool = false
    @Published public var activeFilterCategory: FilterCategory? = nil
    @Published public var selectedStatuses: Set<InvoiceStatus> = []
    @Published public var selectedDateType: DateType = .issueDate
    @Published public var customFromDate: Date? = nil
    @Published public var customToDate: Date? = nil
    @Published public var selectedDatePreset: DateRangePreset? = nil
    @Published public var selectedCustomers: Set<String> = []
    @Published public var selectedSalesperson: String? = nil
    @Published public var selectedBranch: String? = nil
    @Published public var selectedCreatedBy: String? = nil
    @Published public var selectedPaymentStatus: PaymentStatusFilter = .all
    @Published public var selectedCurrencyFilter: String = "All"
    @Published public var minAmountText: String = ""
    @Published public var maxAmountText: String = ""
    @Published public var quickAmountRange: AmountQuickRange? = nil

    public init() {}

    // MARK: - Filtered Dataset Computation

    public var filteredInvoices: [Invoice] {
        var result = invoices

        // 1. Status Filter
        if !selectedStatuses.isEmpty {
            result = result.filter { selectedStatuses.contains($0.status) }
        } else if let targetStatus = selectedFilterChip.statusValue {
            result = result.filter { $0.status == targetStatus }
        }

        // 2. Search Text
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { inv in
                inv.invoiceId.lowercased().contains(query) ||
                inv.customerName.lowercased().contains(query) ||
                (inv.poReference?.lowercased().contains(query) ?? false) ||
                (inv.salesperson?.lowercased().contains(query) ?? false) ||
                inv.status.rawValue.lowercased().contains(query) ||
                inv.formattedTotal.lowercased().contains(query)
            }
        }

        // 3. Customer Filter
        if !selectedCustomers.isEmpty {
            result = result.filter { selectedCustomers.contains($0.customerName) }
        }

        // 4. Salesperson Filter
        if let sp = selectedSalesperson, !sp.isEmpty {
            result = result.filter { $0.salesperson == sp }
        }

        // 5. Branch Filter
        if let branch = selectedBranch, !branch.isEmpty {
            result = result.filter { $0.branch == branch }
        }

        // 6. Created By Filter
        if let creator = selectedCreatedBy, !creator.isEmpty {
            result = result.filter { $0.createdBy == creator }
        }

        // 7. Currency Filter
        if selectedCurrencyFilter != "All" {
            result = result.filter { $0.currency == selectedCurrencyFilter }
        }

        // 8. Payment Status Filter
        switch selectedPaymentStatus {
        case .all: break
        case .paid: result = result.filter { $0.status == .paid }
        case .partial: result = result.filter { $0.status == .partiallyPaid }
        case .unpaid: result = result.filter { $0.status != .paid }
        }

        // 9. Amount Range Filter
        if let minVal = Double(minAmountText) {
            result = result.filter { $0.totalAmount >= minVal }
        }
        if let maxVal = Double(maxAmountText) {
            result = result.filter { $0.totalAmount <= maxVal }
        }
        if let quickRange = quickAmountRange {
            let (minR, maxR) = quickRange.minMax
            if let minR { result = result.filter { $0.totalAmount >= minR } }
            if let maxR { result = result.filter { $0.totalAmount <= maxR } }
        }

        // 10. Date Range Filter
        let calendar = Calendar.current
        let now = Date()

        if let preset = selectedDatePreset {
            result = result.filter { inv in
                let targetDate = (selectedDateType == .issueDate) ? inv.issueDate : inv.dueDate
                switch preset {
                case .today: return calendar.isDateInToday(targetDate)
                case .yesterday: return calendar.isDateInYesterday(targetDate)
                case .thisWeek: return calendar.isDate(targetDate, equalTo: now, toGranularity: .weekOfYear)
                case .lastWeek:
                    if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: now) {
                        return calendar.isDate(targetDate, equalTo: lastWeek, toGranularity: .weekOfYear)
                    }
                    return true
                case .thisMonth: return calendar.isDate(targetDate, equalTo: now, toGranularity: .month)
                case .lastMonth:
                    if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) {
                        return calendar.isDate(targetDate, equalTo: lastMonth, toGranularity: .month)
                    }
                    return true
                case .thisQuarter: return calendar.isDate(targetDate, equalTo: now, toGranularity: .quarter)
                case .thisYear: return calendar.isDate(targetDate, equalTo: now, toGranularity: .year)
                }
            }
        } else {
            if let fromDate = customFromDate {
                result = result.filter { inv in
                    let targetDate = (selectedDateType == .issueDate) ? inv.issueDate : inv.dueDate
                    return targetDate >= calendar.startOfDay(for: fromDate)
                }
            }
            if let toDate = customToDate {
                result = result.filter { inv in
                    let targetDate = (selectedDateType == .issueDate) ? inv.issueDate : inv.dueDate
                    return targetDate <= (calendar.date(bySettingHour: 23, minute: 59, second: 59, of: toDate) ?? toDate)
                }
            }
        }

        // 11. Sort Results
        result.sort { lhs, rhs in
            switch sortField {
            case .date:
                return sortAscending ? lhs.issueDate < rhs.issueDate : lhs.issueDate > rhs.issueDate
            case .dueDate:
                return sortAscending ? lhs.dueDate < rhs.dueDate : lhs.dueDate > rhs.dueDate
            case .invoiceNumber:
                return sortAscending ? lhs.invoiceId < rhs.invoiceId : lhs.invoiceId > rhs.invoiceId
            case .amount:
                return sortAscending ? lhs.totalAmount < rhs.totalAmount : lhs.totalAmount > rhs.totalAmount
            case .customerName:
                return sortAscending ? lhs.customerName < rhs.customerName : lhs.customerName > rhs.customerName
            case .status:
                return sortAscending ? lhs.status.rawValue < rhs.status.rawValue : lhs.status.rawValue > rhs.status.rawValue
            }
        }

        return result
    }

    // MARK: - KPI Summary Metrics

    public var totalOutstandingAmount: Double {
        invoices.filter { $0.status != .paid && $0.status != .void && $0.status != .cancelled && $0.status != .archived }
            .reduce(0) { $0 + $1.balanceDue }
    }

    public var totalOutstandingCount: Int {
        invoices.filter { $0.status != .paid && $0.status != .void && $0.status != .cancelled && $0.status != .archived }.count
    }

    public var totalBilledAmount: Double {
        invoices.reduce(0) { $0 + $1.totalAmount }
    }

    public var outstandingPercentageText: String {
        guard totalBilledAmount > 0 else { return "0%" }
        let pct = (totalOutstandingAmount / totalBilledAmount) * 100.0
        return String(format: "%.1f%% of total", pct)
    }

    public var overdueAmount: Double {
        invoices.filter { $0.isOverdue }.reduce(0) { $0 + $1.balanceDue }
    }

    public var overdueCount: Int {
        invoices.filter { $0.isOverdue }.count
    }

    public var dueThisWeekAmount: Double {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return invoices.filter { $0.status != .paid && $0.dueDate >= now && $0.dueDate <= sevenDaysLater }
            .reduce(0) { $0 + $1.balanceDue }
    }

    public var dueThisWeekCount: Int {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return invoices.filter { $0.status != .paid && $0.dueDate >= now && $0.dueDate <= sevenDaysLater }.count
    }

    public var paidThisMonthAmount: Double {
        let calendar = Calendar.current
        let now = Date()
        return invoices.filter { inv in
            inv.status == .paid && calendar.isDate(inv.dueDate, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.totalAmount }
    }

    public var collectionRatePercentage: Double {
        guard totalBilledAmount > 0 else { return 84.5 }
        let totalPaid = invoices.reduce(0) { $0 + $1.paidAmount }
        return min(100.0, (totalPaid / totalBilledAmount) * 100.0)
    }

    public func countForFilterChip(_ chip: InvoiceFilterChip) -> Int {
        if chip == .all {
            return invoices.count
        }
        guard let st = chip.statusValue else { return 0 }
        return invoices.filter { $0.status == st }.count
    }

    public var allCustomerNames: [String] {
        Array(Set(invoices.map { $0.customerName })).sorted()
    }

    public var allSalespersons: [String] {
        Array(Set(invoices.compactMap { $0.salesperson })).sorted()
    }

    public var allBranches: [String] {
        Array(Set(invoices.compactMap { $0.branch })).sorted()
    }

    public var activeFilterCount: Int {
        var count = 0
        if !selectedStatuses.isEmpty { count += 1 }
        if selectedDatePreset != nil || customFromDate != nil || customToDate != nil { count += 1 }
        if !selectedCustomers.isEmpty { count += 1 }
        if selectedSalesperson != nil { count += 1 }
        if selectedBranch != nil { count += 1 }
        if selectedPaymentStatus != .all { count += 1 }
        if selectedCurrencyFilter != "All" { count += 1 }
        if !minAmountText.isEmpty || !maxAmountText.isEmpty || quickAmountRange != nil { count += 1 }
        return count
    }

    public func subtitleForCategory(_ category: FilterCategory) -> String {
        switch category {
        case .status:
            return selectedStatuses.isEmpty ? "All Statuses" : "\(selectedStatuses.count) selected"
        case .dateRange:
            if let preset = selectedDatePreset {
                return preset.rawValue
            } else if customFromDate != nil || customToDate != nil {
                return "Custom Range"
            }
            return "All Time"
        case .currency:
            return selectedCurrencyFilter
        case .paymentStatus:
            return selectedPaymentStatus.rawValue
        case .amount:
            if let quick = quickAmountRange {
                return quick.rawValue
            } else if !minAmountText.isEmpty || !maxAmountText.isEmpty {
                return "Custom Range"
            }
            return "Any Amount"
        case .customer:
            return selectedCustomers.isEmpty ? "All Customers" : "\(selectedCustomers.count) selected"
        case .salesperson:
            return selectedSalesperson ?? "All Salespersons"
        case .branch:
            return selectedBranch ?? "All Branches"
        }
    }

    public func toggleFilterCategory(_ category: FilterCategory) {
        if activeFilterCategory == category {
            activeFilterCategory = nil
        } else {
            activeFilterCategory = category
        }
    }

    public func clearAllFilters() {
        selectedStatuses.removeAll()
        selectedDatePreset = nil
        customFromDate = nil
        customToDate = nil
        selectedCustomers.removeAll()
        selectedSalesperson = nil
        selectedBranch = nil
        selectedCreatedBy = nil
        selectedPaymentStatus = .all
        selectedCurrencyFilter = "All"
        minAmountText = ""
        maxAmountText = ""
        quickAmountRange = nil
        searchText = ""
        selectedFilterChip = .all
        activeFilterCategory = nil
    }

    public func toggleSelectAll() {
        let allIDs = Set(filteredInvoices.map { $0.invoiceId })
        if selectedInvoiceIDs.count >= allIDs.count {
            selectedInvoiceIDs.removeAll()
        } else {
            selectedInvoiceIDs = allIDs
        }
    }

    public func toggleSelection(_ id: String) {
        if selectedInvoiceIDs.contains(id) {
            selectedInvoiceIDs.remove(id)
        } else {
            selectedInvoiceIDs.insert(id)
        }
    }

    public func updateStatus(for invoice: Invoice, newStatus: InvoiceStatus) {
        if let idx = invoices.firstIndex(where: { $0.invoiceId == invoice.invoiceId }) {
            invoices[idx].status = newStatus
            if newStatus == .paid {
                invoices[idx].paidAmount = invoices[idx].totalAmount
                invoices[idx].balanceDue = 0
            }
        }
    }

    public func bulkUpdateStatus(newStatus: InvoiceStatus) {
        for inv in invoices where selectedInvoiceIDs.contains(inv.invoiceId) {
            updateStatus(for: inv, newStatus: newStatus)
        }
        selectedInvoiceIDs.removeAll()
    }

    public func bulkDelete() {
        invoices.removeAll { selectedInvoiceIDs.contains($0.invoiceId) }
        selectedInvoiceIDs.removeAll()
    }

    public func fetchInvoices() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 300_000_000)
        self.invoices = InvoiceController.generateComprehensiveDemoInvoices()
        self.state = .loaded
        if selectedInvoice == nil {
            selectedInvoice = invoices.first
        }
    }

    public func toggleSortOrder() {
        sortAscending.toggle()
    }

    public static func generateComprehensiveDemoInvoices() -> [Invoice] {
        let now = Date()
        let day: TimeInterval = 86400

        var inv1 = Invoice(
            invoiceId: "INV-2026-001",
            customerName: "Acme Industrial Corp",
            customerEmail: "accounts@acmeind.com",
            customerPhone: "+91 98765 43210",
            gstin: "27AAACA12341Z1",
            billingAddress: "Plot 42, MIDC Industrial Area, Mumbai, MH 400093",
            shippingAddress: "Gate 3 Warehouse, MIDC Industrial Area, Mumbai, MH 400093",
            issueDate: now.addingTimeInterval(-day * 15),
            dueDate: now.addingTimeInterval(-day * 2),
            status: .paid,
            currency: "INR",
            companyName: "MetaCortex Solutions India Pvt Ltd",
            paymentTerms: "Net 15",
            poReference: "PO-2026-889",
            salesperson: "Rajesh Kumar",
            branch: "Mumbai Central",
            project: "Factory Automation",
            createdBy: "Priya Sharma",
            notes: "Thank you for your business! Payment received in full.",
            termsAndConditions: "1. Payment within terms. 2. Goods once sold are subject to warranty.",
            totalAmount: 245000.0,
            balanceDue: 0.0,
            items: [
                InvoiceItem(name: "Industrial Automation Server Unit", itemDescription: "Dual Intel Xeon ERP Rack Unit", hsn: "8471", quantity: 2, rate: 100000.0, discount: 5000.0, gstRate: 18.0),
                InvoiceItem(name: "SCADA Control Sensor Array", itemDescription: "IoT Temperature & Pressure Probe Set", hsn: "9031", quantity: 5, rate: 10000.0, discount: 0.0, gstRate: 18.0)
            ],
            payments: [
                InvoicePayment(date: now.addingTimeInterval(-day * 3), method: "NEFT / Bank Transfer", amount: 245000.0, referenceNumber: "UTR99882211")
            ]
        )
        inv1.recalculateTotals()

        var inv2 = Invoice(
            invoiceId: "INV-2026-002",
            customerName: "Globex Logistics Systems",
            customerEmail: "finance@globex.in",
            issueDate: now.addingTimeInterval(-day * 5),
            dueDate: now.addingTimeInterval(day * 25),
            status: .sent,
            currency: "INR",
            poReference: "PO-GLX-402",
            totalAmount: 118000.0,
            balanceDue: 118000.0,
            items: [InvoiceItem(name: "Fleet Tracking License", quantity: 1, rate: 100000.0, gstRate: 18.0)]
        )
        inv2.recalculateTotals()

        var inv3 = Invoice(
            invoiceId: "INV-2026-003",
            customerName: "Soylent Pharmaceuticals",
            issueDate: now.addingTimeInterval(-day * 45),
            dueDate: now.addingTimeInterval(-day * 15),
            status: .overdue,
            currency: "INR",
            poReference: "PO-SOY-901",
            totalAmount: 354000.0,
            balanceDue: 354000.0,
            items: [InvoiceItem(name: "FDA Audit Module", quantity: 1, rate: 300000.0, gstRate: 18.0)]
        )
        inv3.recalculateTotals()

        var inv4 = Invoice(
            invoiceId: "INV-2026-004",
            customerName: "Initech Information Systems",
            issueDate: now,
            dueDate: now.addingTimeInterval(day * 30),
            status: .draft,
            currency: "INR",
            poReference: "PO-INI-007",
            totalAmount: 88500.0,
            balanceDue: 88500.0
        )
        inv4.items = [InvoiceItem(name: "Payroll Setup Consultation", quantity: 20, rate: 3750.0, gstRate: 18.0)]
        inv4.recalculateTotals()

        var inv5 = Invoice(
            invoiceId: "INV-2026-005",
            customerName: "Umbrella Health Tech",
            issueDate: now.addingTimeInterval(-day * 10),
            dueDate: now.addingTimeInterval(day * 20),
            status: .partiallyPaid,
            currency: "INR",
            poReference: "PO-UMB-303",
            totalAmount: 500000.0,
            balanceDue: 250000.0,
            payments: [InvoicePayment(date: now.addingTimeInterval(-day * 8), method: "RTGS", amount: 250000.0, referenceNumber: "RTGS77119933")]
        )
        inv5.items = [InvoiceItem(name: "TeleMedicine Platform Core", quantity: 1, rate: 423728.81, gstRate: 18.0)]
        inv5.recalculateTotals()

        return [inv1, inv2, inv3, inv4, inv5]
    }
}
