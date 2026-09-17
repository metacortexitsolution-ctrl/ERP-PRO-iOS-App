//
//  CommonCurrencyFormatter.swift
//  ERP-PRO-iOS-App
//

import Foundation

public struct CommonCurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencySymbol = "₹"
        fmt.maximumFractionDigits = 0
        return fmt
    }()
    
    public static func format(_ amount: Double?) -> String {
        guard let amount = amount else { return "₹0" }
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(Int(amount))"
    }
}
