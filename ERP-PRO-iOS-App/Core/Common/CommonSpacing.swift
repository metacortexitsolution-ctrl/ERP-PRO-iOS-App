//
//  CommonSpacing.swift
//  ERP-PRO-iOS-App
//

import CoreGraphics

public struct CommonSpacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 12
    public static let lg: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    
    // System Spacing Specification
    public static let micro: CGFloat = 4
    public static let tight: CGFloat = 8
    public static let small: CGFloat = 12
    public static let standard: CGFloat = 16
    public static let cardSpacing: CGFloat = DeviceInfo.isPad ? 24 : 20
    public static let sectionSpacing: CGFloat = DeviceInfo.isPad ? 24 : 20
    public static let pageMargin: CGFloat = DeviceInfo.isPad ? 24 : 16
    public static let headingToCardSpacing: CGFloat = 8

    public static let cardPadding: CGFloat = DeviceInfo.isPad ? 18 : 14
    public static let elementSpacing: CGFloat = 12
    
    // Native Sidebar Specification
    public static let sidebarRowHeight: CGFloat = 44
    public static let sidebarWidth: CGFloat = 320
    public static let sidebarHorizontalPadding: CGFloat = 12
    public static let sidebarTopBottomPadding: CGFloat = 16
    public static let sidebarItemSpacing: CGFloat = 3
    public static let sidebarSectionHeaderTopPadding: CGFloat = 24
    public static let sidebarSectionHeaderBottomPadding: CGFloat = 8
    public static let sidebarIconTextSpacing: CGFloat = 12
    public static let sidebarSelectionCornerRadius: CGFloat = 10
    public static let companyAvatarSize: CGFloat = 38
    public static let badgeHeight: CGFloat = 24
    public static let searchFieldHeight: CGFloat = 38
    
    public static let dividerWidth: CGFloat = 1

    public static let cornerRadiusSm: CGFloat = 8
    public static let cornerRadiusMd: CGFloat = 14
    public static let cornerRadiusLg: CGFloat = 16
    public static let cardCornerRadius: CGFloat = 14
}

