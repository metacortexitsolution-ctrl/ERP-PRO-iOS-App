//
//  CardModifier.swift
//  ERP-PRO-iOS-App
//

import SwiftUI

public struct CardContainerModifier: ViewModifier {
    var cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = CommonSpacing.cardCornerRadius) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(CommonColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CommonColor.cardBorder, lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

public extension View {
    func cardContainer(cornerRadius: CGFloat = CommonSpacing.cardCornerRadius) -> some View {
        self.modifier(CardContainerModifier(cornerRadius: cornerRadius))
    }
}
