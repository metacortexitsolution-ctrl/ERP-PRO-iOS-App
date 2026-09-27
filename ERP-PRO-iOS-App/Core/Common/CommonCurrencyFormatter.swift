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
    
    public static func format(_ amount: Double?, currencyCode: String? = nil) -> String {
        guard let amount = amount else { return "₹0" }
        if let code = currencyCode, code != "INR" {
            let symbol = code == "USD" ? "$" : (code == "EUR" ? "€" : "\(code) ")
            return "\(symbol)\(Int(amount))"
        }
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(Int(amount))"
    }
}
