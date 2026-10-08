//
//  SalesOrderModel.swift
//  ERP-PRO-iOS-App
//

import Foundation
import SwiftUI

// MARK: - Sales Order Line Item

public struct SalesOrderItem: Identifiable, Codable, Hashable {
    public var id: String
    public var name: String
    public var itemDescription: String?
    public var quantity: Double
    public var rate: Double
    public var taxRate: Double
    public var amount: Double

    public init(
        id: String = UUID().uuidString,
        name: String,
        itemDescription: String? = nil,
        quantity: Double = 1.0,
        rate: Double = 0.0,
        taxRate: Double = 18.0
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.rate = rate
        self.taxRate = taxRate
        let subtotal = quantity * rate
        self.amount = subtotal + (subtotal * taxRate / 100.0)
    }
}

// MARK: - Sales Order Lifecycle Status

public enum SalesOrderStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case partiallyDelivered = "Partially Delivered"
    case delivered = "Delivered"
    case invoiced = "Invoiced"
    case cancelled = "Cancelled"
    case closed = "Closed"

    public var id: String { rawValue }

    public var badgeTextColor: Color {
        switch self {
        case .delivered:
            return Color(red: 0.12, green: 0.58, blue: 0.28)
        case .approved:
            return Color(red: 0.18, green: 0.45, blue: 0.96)
        case .invoiced:
            return Color(red: 0.45, green: 0.25, blue: 0.85)
        case .pendingApproval, .partiallyDelivered:
            return Color(red: 0.78, green: 0.48, blue: 0.05)
        case .cancelled:
            return Color(red: 0.85, green: 0.22, blue: 0.22)
        case .draft, .closed:
            return Color(red: 0.4, green: 0.4, blue: 0.45)
        }
    }

    public var badgeBackgroundColor: Color {
        switch self {
        case .delivered:
            return Color(red: 0.88, green: 0.96, blue: 0.90)
        case .approved:
            return Color(red: 0.90, green: 0.94, blue: 1.0)
        case .invoiced:
            return Color(red: 0.93, green: 0.90, blue: 0.99)
        case .pendingApproval, .partiallyDelivered:
            return Color(red: 0.99, green: 0.94, blue: 0.82)
        case .cancelled:
            return Color(red: 0.99, green: 0.88, blue: 0.88)
        case .draft, .closed:
            return Color(uiColor: .systemGray5)
        }
    }

    public var iconName: String {
        switch self {
        case .draft: return "square.and.pencil"
        case .pendingApproval: return "clock.badge.exclamationmark"
        case .approved: return "checkmark.seal.fill"
        case .partiallyDelivered: return "truck.box"
        case .delivered: return "truck.box.fill"
        case .invoiced: return "doc.richtext"
        case .cancelled: return "xmark.circle.fill"
        case .closed: return "lock.fill"
        }
    }
}

// MARK: - Status Filter Chips

public enum SalesOrderFilterChip: String, CaseIterable, Identifiable, Hashable {
    case all = "All"
    case draft = "Draft"
    case pendingApproval = "Pending Approval"
    case approved = "Approved"
    case partiallyDelivered = "Partially Delivered"
    case delivered = "Delivered"
    case invoiced = "Invoiced"
    case cancelled = "Cancelled"
    case closed = "Closed"

    public var id: String { rawValue }

    public var statusValue: SalesOrderStatus? {
        SalesOrderStatus(rawValue: rawValue)
    }
}

// MARK: - Sort & Column Customization Enums

public enum SalesOrderSortField: String, CaseIterable, Identifiable {
    case orderDate = "Order Date"
    case deliveryDate = "Delivery Date"
    case orderId = "Order #"
    case amount = "Amount"
    case customerName = "Customer"
    case status = "Status"

    public var id: String { rawValue }
}

public enum SalesOrderOptionalColumn: String, CaseIterable, Identifiable {
    case salesperson = "Salesperson"
    case branch = "Branch"
    case poReference = "PO #"
    case unbilledAmount = "Unbilled Amount"
    case createdBy = "Created By"

    public var id: String { rawValue }
}

// MARK: - Sales Order Main Model

public struct SalesOrder: Identifiable, Codable, Hashable {
    public var id: String { orderId }
    public var orderId: String
    public var customerName: String
    public var customerEmail: String?
    public var customerPhone: String?
    public var poReference: String?
    public var orderDate: Date
    public var deliveryDate: Date
    public var status: SalesOrderStatus
    public var currency: String
    public var totalAmount: Double
    public var unbilledAmount: Double
    public var salesperson: String?
    public var branch: String?
    public var createdBy: String?
    public var notes: String?
    public var items: [SalesOrderItem]

    public init(
        orderId: String,
        customerName: String,
        customerEmail: String? = nil,
        customerPhone: String? = nil,
        poReference: String? = nil,
        orderDate: Date = Date(),
        deliveryDate: Date = Date().addingTimeInterval(86400 * 14),
        status: SalesOrderStatus = .draft,
        currency: String = "INR",
        totalAmount: Double = 0.0,
        unbilledAmount: Double = 0.0,
        salesperson: String? = nil,
        branch: String? = nil,
        createdBy: String? = nil,
        notes: String? = nil,
        items: [SalesOrderItem] = []
    ) {
        self.orderId = orderId
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.poReference = poReference
        self.orderDate = orderDate
        self.deliveryDate = deliveryDate
        self.status = status
        self.currency = currency
        self.totalAmount = totalAmount
        self.unbilledAmount = unbilledAmount
        self.salesperson = salesperson
        self.branch = branch
        self.createdBy = createdBy
        self.notes = notes
        self.items = items
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

    public var formattedUnbilled: String {
        return CommonCurrencyFormatter.format(unbilledAmount, currencyCode: currency)
    }

    public var formattedOrderDate: String {
        return CommonDateFormatter.formatShort(orderDate)
    }

    public var formattedDeliveryDate: String {
        return CommonDateFormatter.formatShort(deliveryDate)
    }

    public var isOverdue: Bool {
        return status != .delivered && status != .invoiced && status != .closed && status != .cancelled && deliveryDate < Date()
    }
}
