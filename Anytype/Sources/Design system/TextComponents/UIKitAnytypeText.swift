//
//  UIKitAnytypeText.swift
//  Anytype
//
//  Created by Denis Batvinkin on 26.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import AnytypeCore


final class UIKitAnytypeText: Hashable {
    private let paragraphStyle: NSParagraphStyle
    private let textModifier: MarkStyleModifier

    let font: UIFont
    let anytypeFont: AnytypeFont
    let attrString: NSAttributedString

    convenience init(text: String, style: AnytypeFont) {
        self.init(attributedString: NSAttributedString(string: text), style: style)
    }

    init(attributedString: NSAttributedString, style: AnytypeFont) {
        self.anytypeFont = style
        self.font = UIKitFontBuilder.uiKitFont(font: style)

        let newAttrString = NSMutableAttributedString(attributedString: attributedString)
        textModifier = MarkStyleModifier(attributedText: newAttrString, defaultNonCodeFont: self.font)

        // setup line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = style.lineSpacing

        let range = NSMakeRange(0, newAttrString.length)
        newAttrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)

        // set kern
        if let kern = style.kern {
            newAttrString.addAttribute(.kern, value: kern, range: range)
        }
        newAttrString.addAttribute(.font, value: self.font, range: range)

        attrString = newAttrString
        self.paragraphStyle = paragraphStyle
    }

    var typingAttributes: [NSAttributedString.Key : Any] {
        return [.font: font, .paragraphStyle: paragraphStyle]
    }

    var topBottomTextSpacingForContainer: CGFloat {
        anytypeFont.lineSpacing / 2
    }

    func apply(_ action: MarkStyleAction, range: NSRange) {
        textModifier.apply(action, range: range)
    }

    static func == (lhs: UIKitAnytypeText, rhs: UIKitAnytypeText) -> Bool {
        lhs.attrString == rhs.attrString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(attrString)
    }
}
