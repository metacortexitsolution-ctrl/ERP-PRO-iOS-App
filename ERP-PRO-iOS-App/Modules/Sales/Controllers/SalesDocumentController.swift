//
//  SalesDocumentController.swift
//  ERP-PRO-iOS-App
//

import Foundation
import Combine
import SwiftUI

/// Unified Controller managing state, filtering, metrics, and bulk operations for both Invoices and Sales Orders.
@MainActor
public final class SalesDocumentController: ObservableObject {

    public enum State: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
    }

    public let documentType: SalesDocumentType

    @Published public private(set) var state: State = .loading
    @Published public var documents: [SalesDocument] = []

    // Search & Filter State
    @Published public var searchText: String = ""
    @Published public var selectedFilterChip: SalesDocumentFilterChip = .all
    @Published public var sortField: SalesDocumentSortField = .date
    @Published public var sortAscending: Bool = false

    // Selection & Column Customization State
    @Published public var isEditingMode: Bool = false
    @Published public var selectedDocumentIDs: Set<String> = []
    @Published public var visibleOptionalColumns: Set<SalesDocumentOptionalColumn> = [.salesperson, .branch, .poReference]
    @Published public var selectedDocument: SalesDocument? = nil

    // Sheets & Popovers
    @Published public var isFilterPopoverPresented: Bool = false
    @Published public var isShowingNewSheet: Bool = false
    @Published public var isShowingPDFPreview: Bool = false
    @Published public var isShowingThermalPrintSheet: Bool = false
    @Published public var toastMessage: String? = nil

    // Filter Submenu State Machine
    @Published public var activeFilterCategory: SalesDocumentFilterCategory? = nil
    @Published public var selectedStatuses: Set<SalesDocumentStatus> = []
    @Published public var selectedCustomers: Set<String> = []
    @Published public var selectedSalesperson: String? = nil
    @Published public var selectedBranch: String? = nil
    @Published public var selectedCreatedBy: String? = nil

    public init(documentType: SalesDocumentType) {
        self.documentType = documentType
    }

    // MARK: - Filtered Dataset Computation

    public var filteredDocuments: [SalesDocument] {
        var result = documents

        // 1. Filter by Status
        if !selectedStatuses.isEmpty {
            result = result.filter { selectedStatuses.contains($0.status) }
        } else if let targetStatus = selectedFilterChip.statusValue {
            result = result.filter { $0.status == targetStatus }
        }

        // 2. Filter by Search Query
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter { doc in
                doc.documentId.lowercased().contains(query) ||
                doc.customerName.lowercased().contains(query) ||
                (doc.poReference?.lowercased().contains(query) ?? false) ||
                (doc.salesperson?.lowercased().contains(query) ?? false) ||
                doc.status.rawValue.lowercased().contains(query) ||
                doc.formattedTotal.lowercased().contains(query)
            }
        }

        // 3. Filter by Customer Checklist
        if !selectedCustomers.isEmpty {
            result = result.filter { selectedCustomers.contains($0.customerName) }
        }

        // 4. Filter by Salesperson & Branch
        if let sp = selectedSalesperson, !sp.isEmpty {
            result = result.filter { $0.salesperson == sp }
        }
        if let branch = selectedBranch, !branch.isEmpty {
            result = result.filter { $0.branch == branch }
        }

        // 5. Sort Results
        result.sort { lhs, rhs in
            switch sortField {
            case .date:
                return sortAscending ? lhs.primaryDate < rhs.primaryDate : lhs.primaryDate > rhs.primaryDate
            case .secondaryDate:
                return sortAscending ? lhs.secondaryDate < rhs.secondaryDate : lhs.secondaryDate > rhs.secondaryDate
            case .documentNumber:
                return sortAscending ? lhs.documentId < rhs.documentId : lhs.documentId > rhs.documentId
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

    // MARK: - Dynamic Real-Time KPI Metrics

    public var card1Title: String {
        documentType == .invoice ? ConstantString.totalOutstanding : ConstantString.totalSalesVolume
    }

    public var card1Value: Double {
        if documentType == .invoice {
            return documents.filter { $0.status != .paid && $0.status != .void && $0.status != .cancelled }.reduce(0) { $0 + $1.secondaryAmount }
        } else {
            return documents.reduce(0) { $0 + $1.totalAmount }
        }
    }

    public var card1Subtitle: String {
        if documentType == .invoice {
            let count = documents.filter { $0.status != .paid && $0.status != .void && $0.status != .cancelled }.count
            return "\(count) Unpaid"
        } else {
            return "\(documents.count) Orders"
        }
    }

    public var card2Title: String {
        documentType == .invoice ? ConstantString.overdueAmount : ConstantString.pendingUnfulfilled
    }

    public var card2Value: Double {
        if documentType == .invoice {
            return documents.filter { $0.isOverdue }.reduce(0) { $0 + $1.secondaryAmount }
        } else {
            return documents.filter { $0.status == .draft || $0.status == .pendingApproval || $0.status == .approved || $0.status == .partiallyDelivered }.reduce(0) { $0 + $1.totalAmount }
        }
    }

    public var card2Subtitle: String {
        if documentType == .invoice {
            let count = documents.filter { $0.isOverdue }.count
            return "\(count) Overdue"
        } else {
            let count = documents.filter { $0.status == .draft || $0.status == .pendingApproval || $0.status == .approved || $0.status == .partiallyDelivered }.count
            return "\(count) Unfulfilled"
        }
    }

    public var card3Title: String {
        "DUE THIS WEEK"
    }

    public var card3Value: Double {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return documents.filter { $0.status != .paid && $0.status != .delivered && $0.secondaryDate >= now && $0.secondaryDate <= sevenDaysLater }
            .reduce(0) { $0 + $1.totalAmount }
    }

    public var card3Subtitle: String {
        let now = Date()
        let sevenDaysLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        let count = documents.filter { $0.status != .paid && $0.status != .delivered && $0.secondaryDate >= now && $0.secondaryDate <= sevenDaysLater }.count
        return "\(count) Dues in 7d"
    }

    public var card4Title: String {
        documentType == .invoice ? ConstantString.paidThisMonth : ConstantString.fulfilledThisMonth
    }

    public var card4Value: Double {
        let calendar = Calendar.current
        let now = Date()
        return documents.filter { doc in
            (doc.status == .paid || doc.status == .delivered || doc.status == .invoiced) &&
            calendar.isDate(doc.secondaryDate, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.totalAmount }
    }

    public var card4Subtitle: String {
        "↑ High Rate"
    }

    public var filteredTotalAmount: Double {
        filteredDocuments.reduce(0) { $0 + $1.totalAmount }
    }

    public var filteredSecondaryAmount: Double {
        filteredDocuments.reduce(0) { $0 + $1.secondaryAmount }
    }

    public func countForFilterChip(_ chip: SalesDocumentFilterChip) -> Int {
        if chip == .all {
            return documents.count
        }
        guard let st = chip.statusValue else { return 0 }
        return documents.filter { $0.status == st }.count
    }

    public var allCustomerNames: [String] {
        Array(Set(documents.map { $0.customerName })).sorted()
    }

    public var allSalespersons: [String] {
        Array(Set(documents.compactMap { $0.salesperson })).sorted()
    }

    public var allBranches: [String] {
        Array(Set(documents.compactMap { $0.branch })).sorted()
    }

    public var activeFilterCount: Int {
        var count = 0
        if !selectedStatuses.isEmpty { count += 1 }
        if !selectedCustomers.isEmpty { count += 1 }
        if selectedSalesperson != nil { count += 1 }
        if selectedBranch != nil { count += 1 }
        return count
    }

    public func clearAllFilters() {
        selectedStatuses.removeAll()
        selectedCustomers.removeAll()
        selectedSalesperson = nil
        selectedBranch = nil
        searchText = ""
        selectedFilterChip = .all
    }

    public func toggleSelectAll() {
        let allIDs = Set(filteredDocuments.map { $0.documentId })
        if selectedDocumentIDs.count >= allIDs.count {
            selectedDocumentIDs.removeAll()
        } else {
            selectedDocumentIDs = allIDs
        }
    }

    public func toggleSelection(_ id: String) {
        if selectedDocumentIDs.contains(id) {
            selectedDocumentIDs.remove(id)
        } else {
            selectedDocumentIDs.insert(id)
        }
    }

    public func updateStatus(for document: SalesDocument, newStatus: SalesDocumentStatus) {
        if let idx = documents.firstIndex(where: { $0.documentId == document.documentId }) {
            documents[idx].status = newStatus
            if newStatus == .paid || newStatus == .invoiced {
                documents[idx].secondaryAmount = 0
            }
        }
    }

    public func bulkUpdateStatus(newStatus: SalesDocumentStatus) {
        for doc in documents where selectedDocumentIDs.contains(doc.documentId) {
            updateStatus(for: doc, newStatus: newStatus)
        }
        selectedDocumentIDs.removeAll()
    }

    public func bulkDelete() {
        documents.removeAll { selectedDocumentIDs.contains($0.documentId) }
        selectedDocumentIDs.removeAll()
    }

    public func deleteDocument(_ doc: SalesDocument) {
        documents.removeAll { $0.documentId == doc.documentId }
        if selectedDocumentIDs.contains(doc.documentId) {
            selectedDocumentIDs.remove(doc.documentId)
        }
    }

    public func fetchDocuments() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 300_000_000)
        self.documents = SalesDocumentController.generateDemoDocuments(for: documentType)
        self.state = .loaded
        if selectedDocument == nil {
            selectedDocument = documents.first
        }
    }

    public static func generateDemoDocuments(for type: SalesDocumentType) -> [SalesDocument] {
        let now = Date()
        let day: TimeInterval = 86400

        if type == .invoice {
            let inv1 = SalesDocument(
                documentId: "INV-2026-001",
                documentType: .invoice,
                customerName: "Acme Industrial Corp",
                customerEmail: "accounts@acmeind.com",
                customerPhone: "+91 98765 43210",
                gstin: "27AAACA12341Z1",
                primaryDate: now.addingTimeInterval(-day * 15),
                secondaryDate: now.addingTimeInterval(-day * 2),
                status: .paid,
                currency: "INR",
                poReference: "PO-2026-889",
                salesperson: "Rajesh Kumar",
                branch: "Mumbai Central",
                totalAmount: 245000.0,
                secondaryAmount: 0.0,
                items: [SalesDocumentItem(name: "Industrial Automation Unit", quantity: 2, rate: 100000.0, gstRate: 18.0)]
            )
            let inv2 = SalesDocument(
                documentId: "INV-2026-002",
                documentType: .invoice,
                customerName: "Globex Logistics Systems",
                primaryDate: now.addingTimeInterval(-day * 5),
                secondaryDate: now.addingTimeInterval(day * 25),
                status: .sent,
                currency: "INR",
                poReference: "PO-GLX-402",
                salesperson: "Anita Desai",
                branch: "Bengaluru Tech Hub",
                totalAmount: 118000.0,
                secondaryAmount: 118000.0
            )
            let inv3 = SalesDocument(
                documentId: "INV-2026-003",
                documentType: .invoice,
                customerName: "Soylent Pharmaceuticals",
                primaryDate: now.addingTimeInterval(-day * 45),
                secondaryDate: now.addingTimeInterval(-day * 15),
                status: .overdue,
                currency: "INR",
                salesperson: "Rajesh Kumar",
                totalAmount: 354000.0,
                secondaryAmount: 354000.0
            )
            return [inv1, inv2, inv3]
        } else {
            let so1 = SalesDocument(
                documentId: "SO-2026-001",
                documentType: .salesOrder,
                customerName: "Acme Industrial Corp",
                customerEmail: "purchase@acmeind.com",
                customerPhone: "+91 98765 43210",
                primaryDate: now.addingTimeInterval(-day * 12),
                secondaryDate: now.addingTimeInterval(-day * 2),
                status: .delivered,
                currency: "INR",
                poReference: "PO-8890",
                salesperson: "Rajesh Kumar",
                branch: "Mumbai Central",
                totalAmount: 125000.0,
                secondaryAmount: 0.0,
                items: [SalesDocumentItem(name: "Hydraulic Pump Assembly", quantity: 2, rate: 50000.0, gstRate: 18.0)]
            )
            let so2 = SalesDocument(
                documentId: "SO-2026-002",
                documentType: .salesOrder,
                customerName: "Bharat Electricals Ltd",
                primaryDate: now.addingTimeInterval(-day * 20),
                secondaryDate: now.addingTimeInterval(-day * 1),
                status: .approved,
                currency: "INR",
                poReference: "PO-BEL-405",
                salesperson: "Anita Desai",
                branch: "Bengaluru Tech Hub",
                totalAmount: 345000.0,
                secondaryAmount: 345000.0
            )
            let so3 = SalesDocument(
                documentId: "SO-2026-003",
                documentType: .salesOrder,
                customerName: "Globex Logistics",
                primaryDate: now.addingTimeInterval(-day * 3),
                secondaryDate: now.addingTimeInterval(day * 4),
                status: .pendingApproval,
                currency: "INR",
                salesperson: "Vikram Malhotra",
                totalAmount: 88000.0,
                secondaryAmount: 88000.0
            )
            return [so1, so2, so3]
        }
    }
}
