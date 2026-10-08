//
//  InvoiceModel.swift
//  ERP-PRO-iOS-App
//

import Foundation
import SwiftUI

// MARK: - Invoice Line Item Model

public struct InvoiceItem: Identifiable, Codable, Hashable {
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
    public var cgstAmount: Double?
    public var sgstAmount: Double?
    public var igstAmount: Double?
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
        self.cgstAmount = tax / 2.0
        self.sgstAmount = tax / 2.0
        self.igstAmount = 0.0
        self.amount = taxable + tax
        self.unit = unit
    }
}

// MARK: - Invoice Payment Record Model

public struct InvoicePayment: Identifiable, Codable, Hashable {
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

// MARK: - Invoice Lifecycle Status

public enum InvoiceStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case sent = "Sent"
    case viewed = "Viewed"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    case void = "Void"
    case rejected = "Rejected"
    case refunded = "Refunded"
    case writtenOff = "Written Off"
    case disputed = "Disputed"
    case failedDelivery = "Failed Delivery"
    case scheduled = "Scheduled"
    case expired = "Expired"
    case archived = "Archived"

    public var id: String { rawValue }

    public var badgeTextColor: Color {
        switch self {
        case .paid, .approved:
            return Color(red: 0.12, green: 0.58, blue: 0.28)
        case .sent, .viewed, .scheduled:
            return Color(red: 0.18, green: 0.45, blue: 0.96)
        case .partiallyPaid, .pendingApproval:
            return Color(red: 0.78, green: 0.48, blue: 0.05)
        case .overdue, .cancelled, .rejected, .failedDelivery, .expired:
            return Color(red: 0.85, green: 0.22, blue: 0.22)
        case .draft, .archived, .void, .refunded, .writtenOff, .disputed:
            return Color(red: 0.4, green: 0.4, blue: 0.45)
        }
    }

    public var badgeBackgroundColor: Color {
        switch self {
        case .paid, .approved:
            return Color(red: 0.88, green: 0.96, blue: 0.90)
        case .sent, .viewed, .scheduled:
            return Color(red: 0.90, green: 0.94, blue: 1.0)
        case .partiallyPaid, .pendingApproval:
            return Color(red: 0.99, green: 0.94, blue: 0.82)
        case .overdue, .cancelled, .rejected, .failedDelivery, .expired:
            return Color(red: 0.99, green: 0.88, blue: 0.88)
        case .draft, .archived, .void, .refunded, .writtenOff, .disputed:
            return Color(uiColor: .systemGray5)
        }
    }

    public var iconName: String {
        switch self {
        case .draft: return "square.and.pencil"
        case .pendingApproval: return "clock.arrow.circlepath"
        case .approved: return "checkmark.seal"
        case .sent: return "paperplane.fill"
        case .viewed: return "eye.fill"
        case .partiallyPaid: return "dollarsign.circle"
        case .paid: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .void: return "nosign"
        case .rejected: return "hand.thumbsdown.fill"
        case .refunded: return "arrow.counterclockwise.circle.fill"
        case .writtenOff: return "doc.badge.gearshape"
        case .disputed: return "exclamationmark.bubble.fill"
        case .failedDelivery: return "paperplane.badge.triangle.badge.exclamationmark"
        case .scheduled: return "calendar.badge.clock"
        case .expired: return "timer.slash"
        case .archived: return "archivebox.fill"
        }
    }
}

// MARK: - 19 Filter Chips (All + 18 Lifecycle Statuses)

public enum InvoiceFilterChip: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case sent = "Sent"
    case viewed = "Viewed"
    case partiallyPaid = "Partially Paid"
    case paid = "Paid"
    case overdue = "Overdue"
    case cancelled = "Cancelled"
    case void = "Void"
    case rejected = "Rejected"
    case refunded = "Refunded"
    case writtenOff = "Written Off"
    case disputed = "Disputed"
    case failedDelivery = "Failed Delivery"
    case scheduled = "Scheduled"
    case expired = "Expired"
    case archived = "Archived"

    public var id: String { rawValue }

    public var statusValue: InvoiceStatus? {
        InvoiceStatus(rawValue: rawValue)
    }
}

// MARK: - Advanced Filter Presets & Options

public enum DateRangePreset: String, CaseIterable, Identifiable, Hashable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisQuarter = "This Quarter"
    case thisYear = "This Year"

    public var id: String { rawValue }
}

public enum PaymentStatusFilter: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case paid = "Paid"
    case partial = "Partial"
    case unpaid = "Unpaid"

    public var id: String { rawValue }
}

public enum AmountQuickRange: String, CaseIterable, Identifiable, Hashable {
    case under25k = "<₹25K"
    case range25k100k = "₹25K–₹1L"
    case range100k500k = "₹1L–₹5L"
    case above500k = ">₹5L"

    public var id: String { rawValue }

    public var minMax: (Double?, Double?) {
        switch self {
        case .under25k: return (0, 25000)
        case .range25k100k: return (25000, 100000)
        case .range100k500k: return (100000, 500000)
        case .above500k: return (500000, nil)
        }
    }
}

public enum OptionalColumn: String, CaseIterable, Identifiable, Hashable {
    case salesperson = "Salesperson"
    case currency = "Currency"
    case paymentMethod = "Payment Method"
    case project = "Project"
    case branch = "Branch"
    case tags = "Tags"
    case createdBy = "Created By"
    case lastUpdated = "Last Updated"
    case referenceNo = "Reference #"
    case poReference = "PO #"

    public var id: String { rawValue }
}

// MARK: - Main Invoice Model

public struct Invoice: Identifiable, Codable, Hashable {
    public var id: String { invoiceId }
    public var invoiceId: String
    public var customerName: String
    public var customerEmail: String?
    public var customerPhone: String?
    public var gstin: String?
    public var billingAddress: String?
    public var shippingAddress: String?

    public var issueDate: Date
    public var dueDate: Date
    public var status: InvoiceStatus

    public var subtotalAmount: Double
    public var discountAmount: Double
    public var taxAmount: Double
    public var shippingAmount: Double
    public var totalAmount: Double
    public var paidAmount: Double
    public var balanceDue: Double

    public var currency: String
    public var companyName: String
    public var paymentTerms: String
    public var poReference: String?
    public var salesperson: String?
    public var branch: String?
    public var project: String?
    public var createdBy: String?
    public var notes: String?
    public var termsAndConditions: String?
    public var tags: [String] = []

    public var items: [InvoiceItem] = []
    public var payments: [InvoicePayment] = []

    public var isOverdue: Bool {
        return status != .paid && status != .void && status != .archived && status != .cancelled && dueDate < Date()
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

    public var formattedBalanceDue: String {
        return CommonCurrencyFormatter.format(balanceDue, currencyCode: currency)
    }

    public var formattedIssueDate: String {
        return CommonDateFormatter.formatShort(issueDate)
    }

    public var formattedDueDate: String {
        return CommonDateFormatter.formatShort(dueDate)
    }

    public init(
        invoiceId: String,
        customerName: String,
        customerEmail: String? = nil,
        customerPhone: String? = nil,
        gstin: String? = nil,
        billingAddress: String? = nil,
        shippingAddress: String? = nil,
        issueDate: Date = Date(),
        dueDate: Date = Date().addingTimeInterval(86400 * 30),
        status: InvoiceStatus = .draft,
        currency: String = "INR",
        companyName: String = "MetaCortex Solutions",
        paymentTerms: String = "Net 30",
        poReference: String? = nil,
        salesperson: String? = nil,
        branch: String? = nil,
        project: String? = nil,
        createdBy: String? = nil,
        notes: String? = nil,
        termsAndConditions: String? = nil,
        totalAmount: Double = 0.0,
        balanceDue: Double = 0.0,
        items: [InvoiceItem] = [],
        payments: [InvoicePayment] = []
    ) {
        self.invoiceId = invoiceId
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.gstin = gstin
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.issueDate = issueDate
        self.dueDate = dueDate
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
        self.termsAndConditions = termsAndConditions
        self.subtotalAmount = totalAmount
        self.discountAmount = 0
        self.taxAmount = 0
        self.shippingAmount = 0
        self.totalAmount = totalAmount
        self.paidAmount = max(0, totalAmount - balanceDue)
        self.balanceDue = balanceDue
        self.items = items
        self.payments = payments
    }

    public mutating func recalculateTotals() {
        let sub = items.reduce(0) { $0 + $1.taxableAmount }
        let tax = items.reduce(0) { $0 + $1.taxAmount }
        self.subtotalAmount = sub
        self.taxAmount = tax
        self.totalAmount = sub + tax - discountAmount + shippingAmount
        let paid = payments.reduce(0) { $0 + $1.amount }
        self.paidAmount = paid
        self.balanceDue = max(0, totalAmount - paid)
    }
}
