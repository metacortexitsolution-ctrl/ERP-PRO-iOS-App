//
//  SalesOrderViewModel.swift
//  ERP-PRO-iOS-App
//

import Foundation
import SwiftUI
import Combine

@MainActor
public final class SalesOrderViewModel: ObservableObject {
    @Published public var isLoading: Bool = true
    @Published public var orders: [SalesOrder] = []
    
    // Search & Filter State
    @Published public var searchText: String = ""
    @Published public var selectedFilterChip: SalesOrderFilterChip = .all
    @Published public var selectedStatuses: Set<SalesOrderStatus> = []
    @Published public var selectedSalesperson: String? = nil
    @Published public var selectedBranch: String? = nil

    // Selection & Bulk Action State
    @Published public var selectedOrders: Set<String> = []
    @Published public var selectedOrder: SalesOrder? = nil

    // Sheet / Navigation State
    @Published public var isShowingFilterSheet: Bool = false
    @Published public var isShowingNewOrderSheet: Bool = false
    @Published public var isShowingPDFPreview: Bool = false
    @Published public var toastMessage: String? = nil

    public init() {}

    // MARK: - Filtered Orders Computation

    public var filteredOrders: [SalesOrder] {
        var result = orders

        // 1. Status Filter
        if !selectedStatuses.isEmpty {
            result = result.filter { selectedStatuses.contains($0.status) }
        } else if let chipStatus = selectedFilterChip.statusValue {
            result = result.filter { $0.status == chipStatus }
        }

        // 2. Search Filter
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { order in
                order.orderId.lowercased().contains(query) ||
                order.customerName.lowercased().contains(query) ||
                (order.poReference?.lowercased().contains(query) ?? false) ||
                (order.salesperson?.lowercased().contains(query) ?? false) ||
                order.status.rawValue.lowercased().contains(query) ||
                order.formattedTotal.lowercased().contains(query)
            }
        }

        // 3. Salesperson & Branch Filters
        if let sp = selectedSalesperson, !sp.isEmpty {
            result = result.filter { $0.salesperson == sp }
        }
        if let branch = selectedBranch, !branch.isEmpty {
            result = result.filter { $0.branch == branch }
        }

        // 4. Default Sort: Latest Order Date
        result.sort { $0.orderDate > $1.orderDate }

        return result
    }

    // MARK: - KPI Summary Metrics

    public var totalSalesVolume: Double {
        orders.reduce(0) { $0 + $1.totalAmount }
    }

    public var totalOrdersCount: Int {
        orders.count
    }

    public var pendingUnfulfilledVolume: Double {
        orders.filter { $0.status == .draft || $0.status == .pendingApproval || $0.status == .approved || $0.status == .partiallyDelivered }
            .reduce(0) { $0 + $1.totalAmount }
    }

    public var pendingUnfulfilledCount: Int {
        orders.filter { $0.status == .draft || $0.status == .pendingApproval || $0.status == .approved || $0.status == .partiallyDelivered }.count
    }

    public var dueThisWeekVolume: Double {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return orders.filter { order in
            (order.status != .delivered && order.status != .invoiced && order.status != .closed && order.status != .cancelled) &&
            (order.deliveryDate >= now && order.deliveryDate <= sevenDaysLater)
        }.reduce(0) { $0 + $1.totalAmount }
    }

    public var dueThisWeekCount: Int {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return orders.filter { order in
            (order.status != .delivered && order.status != .invoiced && order.status != .closed && order.status != .cancelled) &&
            (order.deliveryDate >= now && order.deliveryDate <= sevenDaysLater)
        }.count
    }

    public var fulfilledThisMonthVolume: Double {
        let calendar = Calendar.current
        let now = Date()
        return orders.filter { order in
            (order.status == .delivered || order.status == .invoiced) &&
            calendar.isDate(order.deliveryDate, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.totalAmount }
    }

    public var fulfilledThisMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return orders.filter { order in
            (order.status == .delivered || order.status == .invoiced) &&
            calendar.isDate(order.deliveryDate, equalTo: now, toGranularity: .month)
        }.count
    }

    public var fulfilledPercentageText: String {
        guard totalSalesVolume > 0 else { return "↑ 0.0%" }
        let pct = (fulfilledThisMonthVolume / totalSalesVolume) * 100.0
        return String(format: "↑ %.1f%%", pct)
    }

    public var filteredTotalAmount: Double {
        filteredOrders.reduce(0) { $0 + $1.totalAmount }
    }

    public var filteredUnbilledAmount: Double {
        filteredOrders.reduce(0) { $0 + $1.unbilledAmount }
    }

    // MARK: - Status Filter Chip Counts

    public func countForFilterChip(_ chip: SalesOrderFilterChip) -> Int {
        if chip == .all {
            return orders.count
        }
        guard let st = chip.statusValue else { return 0 }
        return orders.filter { $0.status == st }.count
    }

    public var activeFilterCount: Int {
        var count = 0
        if !selectedStatuses.isEmpty { count += 1 }
        if selectedSalesperson != nil { count += 1 }
        if selectedBranch != nil { count += 1 }
        return count
    }

    public func clearAllFilters() {
        selectedStatuses.removeAll()
        selectedFilterChip = .all
        selectedSalesperson = nil
        selectedBranch = nil
        searchText = ""
    }

    // MARK: - Selection Management & Bulk Actions

    public func toggleSelectAll() {
        let allIDs = Set(filteredOrders.map { $0.orderId })
        if selectedOrders.count >= allIDs.count {
            selectedOrders.removeAll()
        } else {
            selectedOrders = allIDs
        }
    }

    public func toggleSelection(_ orderId: String) {
        if selectedOrders.contains(orderId) {
            selectedOrders.remove(orderId)
        } else {
            selectedOrders.insert(orderId)
        }
    }

    public func updateStatus(for order: SalesOrder, newStatus: SalesOrderStatus) {
        if let idx = orders.firstIndex(where: { $0.orderId == order.orderId }) {
            orders[idx].status = newStatus
            if newStatus == .invoiced {
                orders[idx].unbilledAmount = 0.0
            }
        }
    }

    public func sendEmailSelected() {
        toastMessage = "Email sent for \(selectedOrders.count) order(s)."
        selectedOrders.removeAll()
    }

    public func exportSelected() {
        toastMessage = "Exported \(selectedOrders.count) order(s) to CSV."
        selectedOrders.removeAll()
    }

    public func convertToInvoiceSelected() {
        for id in selectedOrders {
            if let idx = orders.firstIndex(where: { $0.orderId == id }) {
                orders[idx].status = .invoiced
                orders[idx].unbilledAmount = 0.0
            }
        }
        toastMessage = "Converted \(selectedOrders.count) order(s) to Invoice."
        selectedOrders.removeAll()
    }

    public func deleteSelected() {
        orders.removeAll { selectedOrders.contains($0.orderId) }
        selectedOrders.removeAll()
    }

    public func deleteOrder(_ order: SalesOrder) {
        orders.removeAll { $0.orderId == order.orderId }
        if selectedOrders.contains(order.orderId) {
            selectedOrders.remove(order.orderId)
        }
    }

    // MARK: - Data Fetching & Demo Generator

    public func fetchOrders() async {
        isLoading = true
        // Simulate network latency
        try? await Task.sleep(nanoseconds: 600_000_000)
        orders = SalesOrderViewModel.generateDemoSalesOrders()
        isLoading = false
    }

    public static func generateDemoSalesOrders() -> [SalesOrder] {
        let now = Date()
        let day: TimeInterval = 86400

        var list: [SalesOrder] = []

        // Order 1: Delivered
        let so1 = SalesOrder(
            orderId: "SO-2026-001",
            customerName: "Acme Industrial Corp",
            customerEmail: "purchase@acmeind.com",
            customerPhone: "+91 98765 43210",
            poReference: "PO-8890",
            orderDate: now.addingTimeInterval(-day * 12),
            deliveryDate: now.addingTimeInterval(-day * 2),
            status: .delivered,
            currency: "INR",
            totalAmount: 125000.0,
            unbilledAmount: 0.0,
            salesperson: "Rajesh Kumar",
            branch: "Mumbai Central",
            items: [
                SalesOrderItem(name: "Hydraulic Pump Assembly", quantity: 2, rate: 50000.0, taxRate: 18.0)
            ]
        )
        list.append(so1)

        // Order 2: Approved / Overdue Delivery
        let so2 = SalesOrder(
            orderId: "SO-2026-002",
            customerName: "Bharat Electricals Ltd",
            customerEmail: "orders@bharatelec.in",
            customerPhone: "+91 98220 11223",
            poReference: "PO-BEL-405",
            orderDate: now.addingTimeInterval(-day * 20),
            deliveryDate: now.addingTimeInterval(-day * 1),
            status: .approved,
            currency: "INR",
            totalAmount: 345000.0,
            unbilledAmount: 345000.0,
            salesperson: "Anita Desai",
            branch: "Bengaluru Tech Hub",
            items: [
                SalesOrderItem(name: "High Voltage Transformer Unit", quantity: 1, rate: 292372.88, taxRate: 18.0)
            ]
        )
        list.append(so2)

        // Order 3: Pending Approval
        let so3 = SalesOrder(
            orderId: "SO-2026-003",
            customerName: "Globex Logistics",
            customerEmail: "ap@globex.in",
            poReference: "PO-GLX-990",
            orderDate: now.addingTimeInterval(-day * 3),
            deliveryDate: now.addingTimeInterval(day * 4),
            status: .pendingApproval,
            currency: "INR",
            totalAmount: 88000.0,
            unbilledAmount: 88000.0,
            salesperson: "Rajesh Kumar",
            branch: "Mumbai Central",
            items: [
                SalesOrderItem(name: "GPS Telematics Sensors", quantity: 10, rate: 7457.63, taxRate: 18.0)
            ]
        )
        list.append(so3)

        // Order 4: Partially Delivered
        let so4 = SalesOrder(
            orderId: "SO-2026-004",
            customerName: "Soylent Pharma Corp",
            customerEmail: "supply@soylentpharma.co.in",
            poReference: "PO-SOY-112",
            orderDate: now.addingTimeInterval(-day * 8),
            deliveryDate: now.addingTimeInterval(day * 2),
            status: .partiallyDelivered,
            currency: "INR",
            totalAmount: 210000.0,
            unbilledAmount: 105000.0,
            salesperson: "Vikram Malhotra",
            branch: "Delhi NCR",
            items: [
                SalesOrderItem(name: "Cleanroom Air Filters", quantity: 50, rate: 3559.32, taxRate: 18.0)
            ]
        )
        list.append(so4)

        // Order 5: Invoiced
        let so5 = SalesOrder(
            orderId: "SO-2026-005",
            customerName: "Initech Information Systems",
            customerEmail: "billing@initech.com",
            poReference: "PO-INI-776",
            orderDate: now.addingTimeInterval(-day * 15),
            deliveryDate: now.addingTimeInterval(-day * 5),
            status: .invoiced,
            currency: "INR",
            totalAmount: 490000.0,
            unbilledAmount: 0.0,
            salesperson: "Anita Desai",
            branch: "Bengaluru Tech Hub",
            items: [
                SalesOrderItem(name: "Server Rack Cabinets", quantity: 4, rate: 103813.56, taxRate: 18.0)
            ]
        )
        list.append(so5)

        // Order 6: Draft
        let so6 = SalesOrder(
            orderId: "SO-2026-006",
            customerName: "Umbrella Health Tech",
            poReference: "PO-UMB-002",
            orderDate: now,
            deliveryDate: now.addingTimeInterval(day * 14),
            status: .draft,
            currency: "INR",
            totalAmount: 65000.0,
            unbilledAmount: 65000.0,
            salesperson: "Vikram Malhotra",
            branch: "Delhi NCR",
            items: [
                SalesOrderItem(name: "Patient Monitoring Software License", quantity: 1, rate: 55084.75, taxRate: 18.0)
            ]
        )
        list.append(so6)

        // Order 7: Cancelled
        let so7 = SalesOrder(
            orderId: "SO-2026-007",
            customerName: "Stark Energy Solutions",
            poReference: "PO-STK-441",
            orderDate: now.addingTimeInterval(-day * 25),
            deliveryDate: now.addingTimeInterval(-day * 10),
            status: .cancelled,
            currency: "INR",
            totalAmount: 180000.0,
            unbilledAmount: 0.0,
            salesperson: "Rajesh Kumar",
            branch: "Mumbai Central"
        )
        list.append(so7)

        // Order 8: Closed
        let so8 = SalesOrder(
            orderId: "SO-2026-008",
            customerName: "Wayne Global Retail",
            poReference: "PO-WYN-909",
            orderDate: now.addingTimeInterval(-day * 30),
            deliveryDate: now.addingTimeInterval(-day * 15),
            status: .closed,
            currency: "INR",
            totalAmount: 520000.0,
            unbilledAmount: 0.0,
            salesperson: "Anita Desai",
            branch: "Bengaluru Tech Hub"
        )
        list.append(so8)

        return list
    }
}
