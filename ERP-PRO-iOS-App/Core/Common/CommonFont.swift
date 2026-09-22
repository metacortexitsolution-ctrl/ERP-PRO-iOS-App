//
//  CommonFont.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct CommonFont {
    // MARK: - Core System Typography Specification
    /// 12 pt — captions, tiny metadata, badges
    public static let captionHelper = Font.system(size: 12, weight: .regular)
    public static let captionBadge = Font.system(size: 12, weight: .semibold)
    public static let sidebarBadge = Font.system(size: 12, weight: .semibold)

    /// 13 pt — sidebar section headers, secondary metadata, company subtitle
    public static let sidebarSectionHeader = Font.system(size: 13, weight: .semibold)
    public static let companySubtitle = Font.system(size: 13, weight: .regular)

    /// 14 pt — secondary text, section labels
    public static let secondaryText = Font.system(size: 14, weight: .regular)
    public static let sectionLabel = Font.system(size: 14, weight: .bold)

    /// 16 pt — body text, card content, form/input text, search text, button text
    public static let bodyMain = Font.system(size: 16, weight: .regular)
    public static let cardTitle = Font.system(size: 16, weight: .bold)
    public static let inputText = Font.system(size: 16, weight: .regular)
    public static let buttonText = Font.system(size: 16, weight: .semibold)
    public static let searchFieldText = Font.system(size: 16, weight: .regular)

    /// 17 pt — sidebar menu items, company title, greeting subtitle
    public static let sidebarMenuItem = Font.system(size: 17, weight: .regular)
    public static let sidebarMenuItemSelected = Font.system(size: 17, weight: .semibold)
    public static let companyTitle = Font.system(size: 17, weight: .semibold)
    public static let greetingSubtitle = Font.system(size: 17, weight: .regular)

    /// 20 pt — section headings
    public static let sectionHeading = Font.system(size: 20, weight: .bold)

    /// 28 pt — dashboard/page titles and main KPI values
    public static let dashboardTitle = Font.system(size: 28, weight: .bold)
    public static let kpiValue = Font.system(size: 28, weight: .bold)

    /// 32 pt — large/high-priority KPI numbers
    public static let kpiLargeNumber = Font.system(size: 32, weight: .bold)

    // MARK: - Compatibility Aliases & Helpers
    public static let sidebarIcon = Font.system(size: 20, weight: .regular)
    public static let sidebarToggleIcon = Font.system(size: 18, weight: .medium)
    public static let searchFieldIcon = Font.system(size: 18, weight: .medium)
    public static let barButtonIcon = Font.system(size: 18, weight: .semibold)
    public static let avatarInitial = Font.system(size: 15, weight: .bold)

    public static let largeTitle = dashboardTitle
    public static let title = dashboardTitle
    public static let title2 = Font.system(size: 22, weight: .bold)
    public static let title3 = sectionHeading
    public static let headline = Font.system(size: 17, weight: .semibold)
    public static let subheadline = secondaryText
    public static let body = bodyMain
    public static let caption = captionHelper
    public static let caption2 = Font.system(size: 11, weight: .regular)

    // KPI Values & Metric fonts
    public static let kpiSubValue = secondaryText

    // MARK: - More Module Screen Fonts
    public static let moreSectionHeader = sectionLabel
    public static let moreSectionAction = Font.system(size: 14, weight: .semibold)
    public static let moreCardTitle = cardTitle
    public static let moreCardSubtitle = secondaryText
    public static let moreCardIcon = Font.system(size: 18, weight: .semibold)
    public static let moreCardIconLarge = Font.system(size: 22, weight: .semibold)
    public static let moreCardBadge = captionBadge
    public static let moreCardChevron = Font.system(size: 14, weight: .semibold)
}

