//
//  InvoiceModel.swift
//  ERP-PRO-iOS-App
//

import Foundation
import SwiftUI

/// Status of an invoice with formatted display and design system color attributes matching design specs.
public enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case paid = "Paid"
    case sent = "Sent"
    case pending = "Pending"
    case overdue = "Overdue"
    case draft = "Draft"

    public var id: String { rawValue }

    public var title: String { rawValue }

    public var badgeTextColor: Color {
        switch self {
        case .paid:
            return Color(red: 0.12, green: 0.58, blue: 0.28)
        case .sent:
            return Color(red: 0.18, green: 0.45, blue: 0.96)
        case .pending:
            return Color(red: 0.78, green: 0.48, blue: 0.05)
        case .overdue:
            return Color(red: 0.85, green: 0.22, blue: 0.22)
        case .draft:
            return Color.secondary
        }
    }

    public var badgeBackgroundColor: Color {
        switch self {
        case .paid:
            return Color(red: 0.88, green: 0.96, blue: 0.90)
        case .sent:
            return Color(red: 0.90, green: 0.94, blue: 1.0)
        case .pending:
            return Color(red: 0.99, green: 0.94, blue: 0.82)
        case .overdue:
            return Color(red: 0.99, green: 0.88, blue: 0.88)
        case .draft:
            return Color(uiColor: .systemGray5)
        }
    }
}

/// Filter categories for the Invoices module sidebar & navigation filters.
public enum InvoiceFilterOption: String, CaseIterable, Identifiable {
    case all = "All Invoices"
    case drafts = "Drafts"
    case sent = "Sent"
    case paid = "Paid"
    case overdue = "Overdue"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var iconName: String {
        switch self {
        case .all: return "doc.text"
        case .drafts: return "doc.badge.ellipsis"
        case .sent: return "paperplane"
        case .paid: return "checkmark.seal"
        case .overdue: return "exclamationmark.triangle"
        }
    }
}

/// Identifiable, Codable model representing an Invoice record.
public struct InvoiceItem: Identifiable, Codable, Hashable {
    public let id: String
    public let invoiceNumber: String
    public let customerName: String
    public let date: String
    public let status: InvoiceStatus
    public let amount: Double

    public var formattedAmount: String {
        CommonCurrencyFormatter.format(amount)
    }

    public init(
        id: String,
        invoiceNumber: String,
        customerName: String,
        date: String,
        status: InvoiceStatus,
        amount: Double
    ) {
        self.id = id
        self.invoiceNumber = invoiceNumber
        self.customerName = customerName
        self.date = date
        self.status = status
        self.amount = amount
    }
}

/// Server response wrapper for Invoice list endpoint.
public struct InvoiceListResponse: Codable {
    public let data: [InvoiceItem]?
    public let message: String?
}
