//
//  CommonFont.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct CommonFont {
    public static let largeTitle = Font.largeTitle.bold()
    public static let title = Font.title.bold()
    public static let title2 = Font.title2.bold()
    public static let title3 = Font.title3.weight(.semibold)
    public static let headline = Font.headline
    public static let subheadline = Font.subheadline
    public static let body = Font.body
    public static let caption = Font.caption
    public static let caption2 = Font.caption2
    
    // KPI Values & Metric fonts
    public static let kpiValue = Font.system(.title, design: .rounded, weight: .bold)
    public static let kpiSubValue = Font.system(.subheadline, design: .rounded, weight: .medium)
}
