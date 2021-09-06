//
//  SwiftUIFont.swift
//  Anytype
//
//  Created by Denis Batvinkin on 17.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI


extension AnytypeFontBuilder {
    static func font(name: FontName, size: CGFloat, weight: Font.Weight) -> Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return Font.custom(name.rawValue, size: scaledSize).weight(weight)
    }

    static func font(textStyle: TextStyle) -> Font {
        return font(name: fontName(textStyle), size: size(textStyle), weight: swiftUIWeight(textStyle))
    }

    private static func swiftUIWeight(_ textStyle: TextStyle) -> Font.Weight {
        switch weight(textStyle) {
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
    static let defaultAnytype = AnytypeFontBuilder.font(textStyle: .caption2Regular)
}
