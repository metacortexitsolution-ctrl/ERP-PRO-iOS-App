//
//  CommonDateFormatter.swift
//  ERP-PRO-iOS-App
//

import Foundation

public struct CommonDateFormatter {
    private static let shortDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        return fmt
    }()
    
    private static let timeFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .none
        fmt.timeStyle = .short
        return fmt
    }()
    
    public static func formatShort(_ date: Date) -> String {
        return shortDateFormatter.string(from: date)
    }
    
    public static func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
}
