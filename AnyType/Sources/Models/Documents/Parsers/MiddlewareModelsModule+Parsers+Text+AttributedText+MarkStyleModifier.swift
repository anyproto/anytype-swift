//
//  MiddlewareModelsModule+Parsers+Text+AttributedText+MarkStyle.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

fileprivate typealias Namespace = MiddlewareModelsModule.Parsers.Text.AttributedText

extension Namespace {
    /// This is a `MarkStyleModifier`
    /// Actually, it applies `MarkStyle` to a `NSAttributedString`.
    /// Also it could gather `MarkStyle` from a `NSAttributedString` and its `Attributes`
    ///
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

// MARK: UITextView
extension Namespace.MarkStyleModifier {
    // MARK: Updating attributes.
    func update(by textView: UITextView) -> Self {
        self.update(typingAttributes: textView.typingAttributes).update(linkAttributes: textView.linkTextAttributes)
    }
}

// MARK: Ranges
extension Namespace.MarkStyleModifier {
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

// MARK: Apply Styles
extension Namespace.MarkStyleModifier {
    typealias MarkStyle = MiddlewareModelsModule.Parsers.Text.AttributedText.MarkStyle
    
    // MARK: Attributes
    private func getAttributes(at range: NSRange) -> [NSAttributedString.Key : Any] {
        switch (attributedString.string.isEmpty, range) {
        // isEmpty & range == zero(0, 0) - assuming that we deleted text. So, we need to apply default typing attributes that are coming from textView.
        case (true, NSRange(location: 0, length: 0)): return self.typingAttributes
            
        // isEmpty & range != zero(0, 0) - strange situation, we can't do that. Error, we guess. In that case we need only empty attributes.
        case (true, _): return [:]
        
        // At the end.
        case let (_, value) where value.location == attributedString.length && value.length == 0: return self.typingAttributes
            
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
    
    @discardableResult
    public func applyStyle(style: MarkStyle, rangeOrWholeString either: RangeEither) -> Self {
        switch either {
        case let .range(value): return applyStyle(style: style, range: value)
        case let .whole(value): return value ? applyStyle(style: style, range: NSRange(location: 0, length: charactersCount())) : self
        }
    }
    
    // MARK: Get Mark Styles
    private func getMarkStyles(at range: NSRange) -> [MarkStyle] {
        MarkStyle.from(attributes: getAttributes(at: range))
    }
    
    /// Get all MarkStyles from a RangeEither ( .whole(Bool) or .range(Range)
    /// - Parameter either: Span parameter. It could be `.whole(Bool)` or `.range(Range)`
    /// - Returns: Returns list of marks that it finds in a span.
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
    
    /// Get specified style from a RangeEither ( .whole(Bool) or .range(Range)
    /// - Parameters:
    ///   - style: Style that we are looking for.
    ///   - either: Span parameter. It could be `.whole(Bool)` or `.range(Range)`
    /// - Returns: Returns specified mark style in a span.
    public func getMarkStyle(style: MarkStyle, at either: RangeEither) -> MarkStyle? {
        switch either {
        case let .range(value): return getMarkStyle(style: style, at: value)
        case let .whole(value): return value ? getMarkStyle(style: style, at: NSRange(location: 0, length: charactersCount())) : nil
        }
    }
}
