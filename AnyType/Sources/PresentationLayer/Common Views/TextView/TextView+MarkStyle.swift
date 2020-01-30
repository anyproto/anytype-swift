//
//  TextView+MarkStyle.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: MarkStyle
extension TextView {
    enum MarkStyle: Equatable, CaseIterable {
        enum Update {
            case empty
            case change([NSAttributedString.Key : Any])
//            case deletedKeys([NSAttributedString.Key])
            case changeAndDeletedKeys([NSAttributedString.Key : Any], [NSAttributedString.Key])
            func attributes() -> [NSAttributedString.Key : Any] {
                switch self {
                case .empty: return [:]
                case let .change(value): return value
                case let .changeAndDeletedKeys(value, _): return value
                }
            }
            func deletedKeys() -> [NSAttributedString.Key] {
                switch self {
                case .empty: return []
                case .change: return []
                case let .changeAndDeletedKeys(_, keys): return keys
                }
            }
        }
        static var allCases: [MarkStyle] {
            return [
                .bold(false),
                .italic(false),
                .keyboard(false),
                .strikethrough(false),
                .underscored(false),
                .textColor(nil),
                .backgroundColor(nil),
                .link(nil)
            ]
        }
        
        // change font to bold
        // turn on, turn off
        // NSAttributedString.Key.font
        case bold(Bool = true)
        
        // change font to italic
        // turn on, turn off
        // NSAttributedString.Key.font
        case italic(Bool = true)
        
        // change font to ???
        // change paragraphStyle to .keyboard
        // turn on, turn off
        // NSAttributedString.Key.font
        // NSAttributedString.Key.paragraphStyle
        case keyboard(Bool = true)
        
        // style also?
        // turn on, turn off
        // NSAttributedString.Key.strikethroughStyle
        case strikethrough(Bool = true)
        
        // style also?
        // turn on, turn off
        // NSAttributedString.Key.underlineStyle
        case underscored(Bool = true)
        
        
        // choose colors
        // NSAttributedString.Key.foregroundColor
        case textColor(UIColor?)
        
        // choose colors
        // NSAttributedString.Key.backgroundColor
        case backgroundColor(UIColor?)
        
        // NOTE: It has DIFFERENT attributes.
        // Actually, .linkAttributes in UITextView.
        // set link
        // NSAttributedString.Key.link
        case link(URL?)
        
        // MARK: Opposite
        func opposite() -> Self {
            switch self {
            case let .bold(value): return
                .bold(!value)
            case let .italic(value): return
                .italic(!value)
            case let .keyboard(value): return
                .keyboard(!value)
            case let .strikethrough(value): return
                .strikethrough(!value)
            case let .underscored(value): return
                .underscored(!value)
                
            case let .textColor(value): return
                .textColor(value) // or nil maybe?
            case let .backgroundColor(value): return
                .backgroundColor(value) // or nil maybe?
            case let .link(value): return
                .link(value) // or nil maybe?
            }
        }
        
        // MARK: Conversion
        func from(attributes: [NSAttributedString.Key : Any]) -> Self? {
            switch self {
            case .bold: return .bold( (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitBold) ?? false )
            case .italic: return .italic( (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitItalic) ?? false )
            case .keyboard: return .keyboard(
                //                (attributes[.font] as? UIFont)
//                (attributes[.paragraphStyle] as? NSParagraphStyle) == NSParagraphStyle.keyboardStyle &&
                (attributes[.font] as? UIFont)?.fontDescriptor.symbolicTraits.contains(.traitMonoSpace) ?? false
                )
            case .strikethrough: return .strikethrough( (attributes[.strikethroughStyle] as? Int) == 1 )
            case .underscored: return .underscored( (attributes[.underlineStyle] as? Int) == 1 )
            case .textColor: return .textColor( attributes[.foregroundColor] as? UIColor )
            case .backgroundColor: return .backgroundColor( attributes[.backgroundColor] as? UIColor )
            case .link: return .link( attributes[.link] as? URL )
            }
        }
        
        // TODO: rethink.
        // Should we make option set here?
        static func from(attributes: [NSAttributedString.Key : Any]) -> [Self] {
            return allCases.compactMap{$0.from(attributes: attributes)}
        }
        
        // CAUTION:
        // This method return ONLY SLIDES of correspoding attributes and can return empty dictionary.
        // Second value in a pair is keys to remove.
        func to(old: [NSAttributedString.Key : Any]) -> Update {
            switch self {
            case let .bold(value):
                if let font = old[.font] as? UIFont {
                    let oldTraits = font.fontDescriptor.symbolicTraits
                    let traits = value ? oldTraits.union(.traitBold) : oldTraits.symmetricDifference(.traitBold)
                    if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont: UIFont = .init(descriptor: newDescriptor, size: font.pointSize)
                        return .change([.font : newFont])
                    }
                }
                return .empty
            case let .italic(value):
                if let font = old[.font] as? UIFont {
                    let oldTraits = font.fontDescriptor.symbolicTraits
                    let traits = value ? oldTraits.union(.traitItalic) : oldTraits.symmetricDifference(.traitItalic)
                    if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                        let newFont: UIFont = .init(descriptor: newDescriptor, size: font.pointSize)
                        return .change([.font : newFont])
                    }
                }
                return .empty
            case let .keyboard(value):
                print("value: \(value)")
                var result: [NSAttributedString.Key : Any] = [:]
                
                if let font = old[.font] as? UIFont {
                    let oldTraits = font.fontDescriptor.symbolicTraits
                    let traits = value ? oldTraits.union(.traitMonoSpace) : oldTraits.symmetricDifference(.traitMonoSpace)
                    // TODO: Simplify
                    // AAAAA
                    // It could be done as italic or bold, but it can't.
                    // .traitMonoSpace change font family, so, we should extract traits and apply them to
                    // value  - current font
                    // !value - preferred body font
                    if let newDescriptor = (value ? font : .preferredFont(forTextStyle: .body)).fontDescriptor.withSymbolicTraits(traits) {
                        let newFont: UIFont = .init(descriptor: newDescriptor, size: font.pointSize)
                        print("font: \(font) \n vs \n \(newFont)")
                        result.merge([.font : newFont], uniquingKeysWith: {(lhs,rhs) in rhs})
                    }
                }
                
                //TODO: Uncomment when you're ready.
                // Maybe don't.
                // It should be inconsistent with .from method.
                // NOTE:
                // We don't care about paragraphStyle, cause we set custom paragraph style IF value is true.
                // otherwise, we set it to default or nil (?)
//                if value {
//                    result.merge([.paragraphStyle: NSParagraphStyle.keyboardStyle], uniquingKeysWith: {(lhs, rhs) in rhs})
//                }
//                else {
//                    // or set it to default
//                    _ = result.removeValue(forKey: .paragraphStyle)
//                }
                
                return .change(result)
            case let .strikethrough(value): return .change([.strikethroughStyle : value ? 1 : 0])
            case let .underscored(value): return .change([ .underlineStyle : value ? 1 : 0 ])
            case let .textColor(value): return .change([ .foregroundColor : value as Any ])
            case let .backgroundColor(value): return .change([ .backgroundColor : value as Any ])
            case let .link(value): return .changeAndDeletedKeys([ .link : value as Any ], value == nil ? [.link] : [])
            }
        }
    }
}

// MARK: KeyboardStyle
// TODO: Add style.
/*
 kbd { display: inline; font-family: 'Mono'; line-height: 1.71; background: rgba(247,245,240,0.5); padding: 2px 4px; border-radius: 2px; }
 */
extension NSParagraphStyle {
    private class KeyboardStyle: NSParagraphStyle {
        override var headIndent: CGFloat {
            return 10.0
        }
        override var tailIndent: CGFloat {
            return 10.0
        }
    }
    fileprivate static var keyboardStyle: NSParagraphStyle = {
        return KeyboardStyle()
    }()
}

// MARK: Range Either
extension TextView {
    enum Either<Left, Right> {
        case left(Left)
        case right(Right)
    }
    enum RangedEither<Left, Right> {
        case range(Left)
        case whole(Right)
    }
    typealias RangeEither = RangedEither<NSRange, Bool>
}

// MARK: MarkStyleModifier
extension TextView {
    class MarkStyleModifier {
        // MARK: Convenient Wrappers
        func charactersCount() -> Int {
            return self.attributedString.length
        }
        
        // MARK: Variables
        var attributedString: NSMutableAttributedString = .init()
        var typingAttributes: [NSAttributedString.Key : Any] = [:]
        var linkAttributes: [NSAttributedString.Key : Any] = [:]
        
        // MARK: Initialization
        init() {}
        init(attributedText: NSMutableAttributedString) {
            attributedString = attributedText
        }
        init(text: String) {
            attributedString = NSMutableAttributedString(string: text)
            attributedString.setAttributes([.font : UIFont.preferredFont(forTextStyle: .body)], range: NSRange(location: 0, length: attributedString.length))
        }
        
        // MARK: Updating attributes.
        func update(by textView: UITextView) -> Self {
            self.update(typingAttributes: textView.typingAttributes).update(linkAttributes: textView.linkTextAttributes)
        }
        
        func update(typingAttributes: [NSAttributedString.Key : Any]) -> Self {
            self.typingAttributes = typingAttributes
            return self
        }
        
        func update(linkAttributes: [NSAttributedString.Key : Any]) -> Self {
            self.linkAttributes = linkAttributes
            return self
        }
    }
}

// MARK: MarkStyleModifier / Apply Styles
extension TextView.MarkStyleModifier {
    typealias MarkStyle = TextView.MarkStyle
    typealias RangeEither = TextView.RangeEither
    
    // MARK: Attributes
    private func getAttributes(at range: NSRange) -> [NSAttributedString.Key : Any] {
        switch (attributedString.string.isEmpty, range) {
        // isEmpty & range == zero(0, 0) - assuming that we deleted text. So, we need to apply default typing attributes that are coming from textView.
        case (true, NSRange(location: 0, length: 0)): return self.typingAttributes
        
        // isEmpty & range != zero(0, 0) - strange situation, we can't do that. Error, we guess. In that case we need only empty attributes.
        case (true, _): return [:]
            
        // Otherwise, return string attributes.
        default: break
        }
        // TODO: We still DON'T check range and attributedString length here. Fix it.
        return attributedString.attributes(at: range.lowerBound, longestEffectiveRange: nil, in: range)
    }
    
    private func mergeAttributes(origin: [NSAttributedString.Key : Any], changes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any] {
        var result = origin
        result.merge(changes) { (source, target) in target }
        return result
    }
    
    // MARK: Applying style
    private func applyStyle(style: MarkStyle, range: NSRange) -> Self {
        let oldAttributes = getAttributes(at: range)
        let update = style.to(old: oldAttributes)
        
        let changedAttributes = update.attributes()
        let deletedKeys = update.deletedKeys()
        
        var newAttributes = self.mergeAttributes(origin: oldAttributes, changes: changedAttributes)
        for key in deletedKeys {
            newAttributes.removeValue(forKey: key)
            attributedString.removeAttribute(key, range: range)
        }

        attributedString.addAttributes(newAttributes, range: range)
        // and send event about it?
        // that attributes at range are changed.
        // also, on selection we should fire event about attributes.
        return self
    }
    
    public func applyStyle(style: MarkStyle, rangeOrWholeString either: RangeEither) -> Self {
        switch either {
        case let .range(value): return applyStyle(style: style, range: value)
        case let .whole(value): return value ? applyStyle(style: style, range: NSRange(location: 0, length: charactersCount())) : self
        }
    }
    
    // MARK: Get Mark Styles
    private func getMarkStyles(at range: NSRange) -> [MarkStyle] {
        TextView.MarkStyle.from(attributes: getAttributes(at: range))
    }
    
    public func getMarkStyles(at either: RangeEither) -> [MarkStyle] {
        switch either {
        case let .range(value): return getMarkStyles(at: value)
        case let .whole(value): return value ? getMarkStyles(at: NSRange(location: 0, length: charactersCount())) : []
        }
    }

    // MARK: Get specific Mark Style
    private func getMarkStyle(style: MarkStyle, at range: NSRange) -> MarkStyle? {
        style.from(attributes: getAttributes(at: range))
    }
    
    public func getMarkStyle(style: MarkStyle, at either: RangeEither) -> MarkStyle? {
        switch either {
        case let .range(value): return getMarkStyle(style: style, at: value)
        case let .whole(value): return value ? getMarkStyle(style: style, at: NSRange(location: 0, length: charactersCount())) : nil
        }
    }
}
