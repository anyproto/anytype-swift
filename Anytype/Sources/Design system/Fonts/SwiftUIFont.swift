//
//  SwiftUIFont.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


struct AnytypeFontBuilder {
    static func font(name: AnytypeFont.FontName, size: CGFloat, weight: Font.Weight) -> Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return Font.custom(name.rawValue, size: scaledSize).weight(weight)
    }

    static func font(anytypeFont: AnytypeFont) -> Font {
        return font(name: anytypeFont.fontName, size: anytypeFont.size, weight: swiftUIWeight(anytypeFont))
    }

    private static func swiftUIWeight(_ font: AnytypeFont) -> Font.Weight {
        switch font.weight {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }
}

extension Font {
    static let defaultAnytype = AnytypeFontBuilder.font(anytypeFont: .caption2Regular)
}

struct OptionalLineSpacingModifier: ViewModifier {
    var spacing: CGFloat?

    func body(content: Content) -> some View {
        spacing.map { spacing in
            // TODO: Negative line spacing not working.
            content.lineSpacing(spacing).eraseToAnyView()
        } ?? content.eraseToAnyView()
    }
}
