//
//  SalesDocumentModel.swift
//  ERP-PRO-iOS-App
//

import Foundation
import SwiftUI

// MARK: - Sales Document Type

public enum SalesDocumentType: String, Codable, CaseIterable, Identifiable, Hashable {
    case invoice = "Invoice"
    case salesOrder = "Sales Order"
    case estimate = "Quotation"
    case deliveryChallan = "Delivery Challan"
    case creditNote = "Credit Note"

    public var id: String { rawValue }

    public var pluralTitle: String {
        switch self {
        case .invoice: return "Invoices"
        case .salesOrder: return "Sales Orders"
        case .estimate: return "Quotations & Estimates"
        case .deliveryChallan: return "Delivery Challans"
        case .creditNote: return "Credit Notes"
        }
    }

    public var newTitle: String {
        switch self {
        case .invoice: return "New Invoice"
        case .salesOrder: return "New Sales Order"
        case .estimate: return "New Quotation"
        case .deliveryChallan: return "New Delivery Challan"
        case .creditNote: return "New Credit Note"
        }
    }

    public var systemIcon: String {
        switch self {
        case .invoice: return "doc.text.fill"
        case .salesOrder: return "cart.fill"
        case .estimate: return "doc.text"
        case .deliveryChallan: return "truck.box"
        case .creditNote: return "doc.badge.plus"
        }
    }
}

// MARK: - Sales Document Line Item

public struct SalesDocumentItem: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var itemDescription: String?
    public var hsn: String
    public var quantity: Double
    public var rate: Double
    public var discount: Double
    public var gstRate: Double
    public var taxableAmount: Double
    public var taxAmount: Double
    public var amount: Double
    public var unit: String

    public init(
        id: String = UUID().uuidString,
        name: String,
        itemDescription: String? = nil,
        hsn: String = "7610",
        quantity: Double = 1.0,
        rate: Double = 0.0,
        discount: Double = 0.0,
        gstRate: Double = 18.0,
        unit: String = "Nos"
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.hsn = hsn
        self.quantity = quantity
        self.rate = rate
        self.discount = discount
        self.gstRate = gstRate
        let taxable = max(0, (quantity * rate) - discount)
        self.taxableAmount = taxable
        let tax = (taxable * gstRate) / 100.0
        self.taxAmount = tax
        self.amount = taxable + tax
        self.unit = unit
    }
}

// MARK: - Sales Document Payment Record

public struct SalesDocumentPayment: Identifiable, Codable, Hashable {
    public var id: String
    public var date: Date
    public var method: String
    public var amount: Double
    public var referenceNumber: String?

    public init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        method: String,
        amount: Double,
        referenceNumber: String? = nil
    ) {
        self.id = id
        self.date = date
        self.method = method
        self.amount = amount
        self.referenceNumber = referenceNumber
    }
}

// MARK: - Sales Document Lifecycle Status

public enum SalesDocumentStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case sent = "Sent"
    case viewed = "Viewed"
    case partiallyDelivered = "Partially Delivered"
    case delivered = "Delivered"
    case invoiced = "Invoiced"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    case void = "Void"
    case closed = "Closed"
    case archived = "Archived"

    public var id: String { rawValue }

    public var badgeTextColor: Color {
        switch self {
        case .paid, .approved, .delivered:
            return Color(red: 0.12, green: 0.58, blue: 0.28)
        case .sent, .viewed:
            return Color(red: 0.18, green: 0.45, blue: 0.96)
        case .invoiced:
            return Color(red: 0.45, green: 0.25, blue: 0.85)
        case .partiallyPaid, .partiallyDelivered, .pendingApproval:
            return Color(red: 0.78, green: 0.48, blue: 0.05)
        case .overdue, .cancelled:
            return Color(red: 0.85, green: 0.22, blue: 0.22)
        case .draft, .archived, .void, .closed:
            return Color(red: 0.4, green: 0.4, blue: 0.45)
        }
    }

    public var badgeBackgroundColor: Color {
        switch self {
        case .paid, .approved, .delivered:
            return Color(red: 0.88, green: 0.96, blue: 0.90)
        case .sent, .viewed:
            return Color(red: 0.90, green: 0.94, blue: 1.0)
        case .invoiced:
            return Color(red: 0.93, green: 0.90, blue: 0.99)
        case .partiallyPaid, .partiallyDelivered, .pendingApproval:
            return Color(red: 0.99, green: 0.94, blue: 0.82)
        case .overdue, .cancelled:
            return Color(red: 0.99, green: 0.88, blue: 0.88)
        case .draft, .archived, .void, .closed:
            return Color(uiColor: .systemGray5)
        }
    }

    public var iconName: String {
        switch self {
        case .draft: return "square.and.pencil"
        case .pendingApproval: return "clock.badge.exclamationmark"
        case .approved: return "checkmark.seal.fill"
        case .sent: return "paperplane.fill"
        case .viewed: return "eye.fill"
        case .partiallyDelivered: return "truck.box"
        case .delivered: return "truck.box.fill"
        case .invoiced: return "doc.richtext"
        case .partiallyPaid: return "dollarsign.circle"
        case .paid: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .void: return "nosign"
        case .closed: return "lock.fill"
        case .archived: return "archivebox.fill"
        }
    }
}

// MARK: - Enums for Filtering, Sorting, Columns

public enum SalesDocumentFilterChip: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case sent = "Sent"
    case partiallyDelivered = "Partially Delivered"
    case delivered = "Delivered"
    case invoiced = "Invoiced"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    case closed = "Closed"

    public var id: String { rawValue }

    public var statusValue: SalesDocumentStatus? {
        SalesDocumentStatus(rawValue: rawValue)
    }
}

public enum SalesDocumentSortField: String, CaseIterable, Identifiable, Hashable {
    case date = "Date"
    case documentNumber = "Document #"
    case amount = "Amount"
    case customerName = "Customer"
    case secondaryDate = "Due/Delivery Date"
    case status = "Status"

    public var id: String { rawValue }
}

public enum SalesDocumentOptionalColumn: String, CaseIterable, Identifiable, Hashable {
    case salesperson = "Salesperson"
    case branch = "Branch"
    case poReference = "PO #"
    case currency = "Currency"
    case secondaryAmount = "Secondary Amount"
    case createdBy = "Created By"

    public var id: String { rawValue }
}

public enum SalesDocumentFilterCategory: String, CaseIterable, Identifiable, Hashable {
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

// MARK: - Main Sales Document Model

public struct SalesDocument: Identifiable, Codable, Hashable {
    public var id: String { documentId }
    public var documentId: String
    public var documentType: SalesDocumentType
    public var customerName: String
    public var customerEmail: String?
    public var customerPhone: String?
    public var gstin: String?
    public var billingAddress: String?
    public var shippingAddress: String?

    public var primaryDate: Date // Issue Date for Invoice / Order Date for Sales Order
    public var secondaryDate: Date // Due Date for Invoice / Delivery Date for Sales Order
    public var status: SalesDocumentStatus

    public var subtotalAmount: Double
    public var taxAmount: Double
    public var totalAmount: Double
    public var secondaryAmount: Double // Balance Due for Invoice / Unbilled Amount for Sales Order

    public var currency: String
    public var companyName: String
    public var paymentTerms: String
    public var poReference: String?
    public var salesperson: String?
    public var branch: String?
    public var project: String?
    public var createdBy: String?
    public var notes: String?

    public var items: [SalesDocumentItem]
    public var payments: [SalesDocumentPayment]

    public init(
        documentId: String,
        documentType: SalesDocumentType,
        customerName: String,
        customerEmail: String? = nil,
        customerPhone: String? = nil,
        gstin: String? = nil,
        billingAddress: String? = nil,
        shippingAddress: String? = nil,
        primaryDate: Date = Date(),
        secondaryDate: Date = Date().addingTimeInterval(86400 * 14),
        status: SalesDocumentStatus = .draft,
        currency: String = "INR",
        companyName: String = "MetaCortex Solutions",
        paymentTerms: String = "Net 30",
        poReference: String? = nil,
        salesperson: String? = nil,
        branch: String? = nil,
        project: String? = nil,
        createdBy: String? = nil,
        notes: String? = nil,
        totalAmount: Double = 0.0,
        secondaryAmount: Double = 0.0,
        items: [SalesDocumentItem] = [],
        payments: [SalesDocumentPayment] = []
    ) {
        self.documentId = documentId
        self.documentType = documentType
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.gstin = gstin
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.primaryDate = primaryDate
        self.secondaryDate = secondaryDate
        self.status = status
        self.currency = currency
        self.companyName = companyName
        self.paymentTerms = paymentTerms
        self.poReference = poReference
        self.salesperson = salesperson
        self.branch = branch
        self.project = project
        self.createdBy = createdBy
        self.notes = notes
        self.subtotalAmount = totalAmount
        self.taxAmount = 0
        self.totalAmount = totalAmount
        self.secondaryAmount = secondaryAmount
        self.items = items
        self.payments = payments
    }

    public var customerInitials: String {
        let components = customerName.components(separatedBy: " ")
        if components.count >= 2, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        }
        return String(customerName.prefix(2)).uppercased()
    }

    public var formattedTotal: String {
        return CommonCurrencyFormatter.format(totalAmount, currencyCode: currency)
    }

    public var formattedSecondaryAmount: String {
        return CommonCurrencyFormatter.format(secondaryAmount, currencyCode: currency)
    }

    public var formattedPrimaryDate: String {
        return CommonDateFormatter.formatShort(primaryDate)
    }

    public var formattedSecondaryDate: String {
        return CommonDateFormatter.formatShort(secondaryDate)
    }

    public var isOverdue: Bool {
        return status != .paid && status != .delivered && status != .invoiced && status != .closed && status != .cancelled && status != .void && secondaryDate < Date()
    }
}
