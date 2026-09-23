//
//  CommonFont.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct CommonFont {
    // MARK: - Core System Typography Specification (iOS / iPadOS)
    
    /// 12 pt — small metadata, captions, tiny badges
    public static let captionHelper = Font.system(size: 12, weight: .regular)
    public static let captionBadge = Font.system(size: 12, weight: .semibold)
    public static let sidebarBadge = Font.system(size: 12, weight: .semibold)
    public static let smallMetadata = Font.system(size: 12, weight: .regular)
    public static let statusBadge = Font.system(size: 12, weight: .semibold)

    /// 13–14 pt — secondary metadata, row subtitles, company subtitle
    public static let sidebarSectionHeader = Font.system(size: 13, weight: .semibold)
    public static let companySubtitle = Font.system(size: 13, weight: .regular)
    public static let secondaryText = Font.system(size: 14, weight: .regular)
    public static let sectionLabel = Font.system(size: 14, weight: .bold)

    /// 16 pt — card titles, body text, form input text, button labels
    public static let bodyMain = Font.system(size: 16, weight: .regular)
    public static let cardTitle = Font.system(size: 16, weight: .semibold)
    public static let inputText = Font.system(size: 16, weight: .regular)
    public static let buttonText = Font.system(size: 16, weight: .semibold)
    public static let searchFieldText = Font.system(size: 16, weight: .regular)

    /// 18–20 pt — card primary values
    public static let cardPrimaryValue = Font.system(size: 20, weight: .bold)

    /// Section Heading — iPad: 22–24pt, iPhone: 21–23pt
    public static var sectionHeading: Font {
        Font.system(size: DeviceInfo.isPad ? 23 : 21, weight: .bold)
    }

    /// Page Title — iPad: 26–28pt, iPhone: 24–26pt
    public static var dashboardTitle: Font {
        Font.system(size: DeviceInfo.isPad ? 28 : 25, weight: .bold)
    }

    /// Main KPI Values (26–28pt)
    public static let kpiValue = Font.system(size: 26, weight: .bold)

    /// KPI Hero Value — iPad: 32–36pt, iPhone: 28–32pt
    public static var kpiHeroValue: Font {
        Font.system(size: DeviceInfo.isPad ? 34 : 30, weight: .bold)
    }
    public static var kpiLargeNumber: Font { kpiHeroValue }

    /// Sidebar typography
    public static let sidebarMenuItem = Font.system(size: 17, weight: .regular)
    public static let sidebarMenuItemSelected = Font.system(size: 17, weight: .semibold)
    public static let companyTitle = Font.system(size: 17, weight: .semibold)
    public static let greetingSubtitle = Font.system(size: 15, weight: .regular)

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

