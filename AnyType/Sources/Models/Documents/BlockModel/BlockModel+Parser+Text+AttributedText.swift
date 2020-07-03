//
//  BlockModel+Parser+Text+AttributedText.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension BlockModels.Parser.Text.AttributedText {
    /// This is Converter between our high-level `NSAttributedString` presentation and low-level middleware String and Marks or `MiddlewareResult` presentation.
    ///
    enum Converter {
        struct MiddlewareResult {
            var text: String
            var marks: Anytype_Model_Block.Content.Text.Marks
        }
        
        static func asModel(text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> NSAttributedString {
            /// Map attributes to our internal format.
            let attributes = marks.marks.map({ value in
                (RangeConverter.asModel(value.range), AttributeConverter.asModel(.init(attribute: value.type, value: value.param)))
            })
            
            /// Create modifier of an attributed string.
            let modifier = MarkStyleModifier.init(attributedText: .init(string: text))
            
            /// We have to set some font, because all styles `change` font attribute.
            /// Not the best place to set attribute, however, we don't have best place...
            ///
            /// Too bad :/
            ///
            let defaultFont: UIFont = .preferredFont(forTextStyle: .body)
            let range: NSRange = .init(location: 0, length: modifier.attributedString.length)
            modifier.attributedString.addAttribute(.font, value: defaultFont, range: range)
            
            /// Apply attributes
            attributes.forEach { value in
                if let attribute = value.1?.attribute {
                    _ = modifier.applyStyle(style: attribute, rangeOrWholeString: .range(value.0))
                }
            }
            
            return modifier.attributedString
        }
        
        static func asMiddleware(attributedText: NSAttributedString) -> MiddlewareResult {
            let wholeText = attributedText.string
            let wholeStringRange: NSRange = .init(location: 0, length: attributedText.length)
                        
            /// 1. Iterate over all ranges in a string.
            var marksStyles: [MarkStyle.HashableKey: NSMutableIndexSet] = [:]
            attributedText.enumerateAttributes(in: wholeStringRange, options: []) { (attributes, range, booleanFlag) in
                
                /// 2. Take all attributes in specific range and convert them to
                let marks = MarkStyle.from(attributes: attributes)
                
                /// Discussion:
                /// This algorithm uses API and feature of `IndexSet` structure.
                /// `IndexSet` combines all ranges into contigous range if possible and minimizes count of data it keeps.
                /// So, instead of enumerate over all ranges and add them, we just add them to current NSIndexSet.
                ///
                /// Consider following set of ranges:
                ///
                /// a      b      c
                /// 0...5, 5...8, 9...10
                ///
                /// When we add them to our indexSet, it will keep them in compact form.
                ///
                /// IndexSet()
                ///
                /// d      e
                /// 0...8, 9...10
                ///
                /// As you see, `d = a + b, e = c`
                ///
                
                /// 3. Iterate over all marks in this range.
                for mark in marks {
                    
                    let key: MarkStyle.HashableKey = .init(markStyle: mark)
                                        
                    /// 4. If key exists, so, we must add range to result indexSet.
                    if let value = marksStyles[key] {
                        value.add(in: range)
                    }
                        
                    /// 5. Otherwise, we should init new indexSet from current range.
                    else {
                        marksStyles[key] = .init(indexesIn: range)
                    }
                }
            }
            
            // Filter out all cases that are "empty".
            let filteredMarkStyles = marksStyles.filter {
                !MarkStyle.emptyCases.contains($0.0.markStyle)
            }
            
            let middlewareMarks = filteredMarkStyles.flatMap { (tuple) -> [Anytype_Model_Block.Content.Text.Mark] in
                let (key, value) = tuple
                let type = AttributeConverter.asMiddleware(.init(attribute: key.markStyle))
                let indexSet: IndexSet = value as IndexSet
                return indexSet.rangeView.enumerated().map {
                    Anytype_Model_Block.Content.Text.Mark.init(range: RangeConverter.asMiddleware(NSRange($0.element)), type: type.attribute, param: type.value)
                }
            }
            
            let wholeMarks: Anytype_Model_Block.Content.Text.Marks = .init(marks: middlewareMarks)
            return .init(text: wholeText, marks: wholeMarks)
        }
    }
}

private extension BlockModels.Parser.Text.AttributedText.MarkStyle {
    struct HashableKey: Hashable {
        var markStyle: BlockModels.Parser.Text.AttributedText.MarkStyle
        private func string(mark: BlockModels.Parser.Text.AttributedText.MarkStyle) -> String {
            switch mark {
            case let .bold(value): return "bold - " + String(describing: value)
            case let .italic(value): return "italic - " + String(describing: value)
            case let .keyboard(value): return "keyboard - " + String(describing: value)
            case let .strikethrough(value): return "strikethrough - " + String(describing: value)
            case let .underscored(value): return "underscored - " + String(describing: value)
            case let .textColor(value): return "textColor - " + String(describing: value)
            case let .backgroundColor(value): return "backgroundColor - " + String(describing: value)
            case let .link(value): return "link - " + String(describing: value)
            }
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(String(describing: markStyle))
        }
    }
}

extension BlockModels.Parser.Text.AttributedText {
    enum RangeConverter {
        /// We have to map correctly range from middleware and our range.
        /// For example, our range equals:
        ///
        /// | Middleware | NSRange |  Description   |
        /// |   (5, 5)   |  (5, 0) | At position 5 and length equal 0 |
        /// |   (0, 1)   |  (0, 1) | At position 0 and length equal 1 |
        /// |   (3, 2)   |  (3, ?) | Invalid case |
        ///
        /// Middleware: (NSRange.from, NSRange.from + NSRange.length )
        ///
        /// NSRange: ( Middleware.from, Middleware.to - Middleware.from )
        ///
        static func asModel(_ range: Anytype_Model_Range) -> NSRange {
            .init(location: Int(range.from), length: Int(range.to) - Int(range.from))
        }
        
        /// As soon as upperBound is equal to ( range.length + range.lowerBound ),
        /// We could safely set
        ///
        static func asMiddleware(_ range: NSRange) -> Anytype_Model_Range {
            .init(from: Int32(range.lowerBound), to: Int32(range.lowerBound + range.length))
        }
    }
}

// MARK: Attribute
private extension BlockModels.Parser.Text.AttributedText {
    enum AttributeConverter {
        struct MiddlewareTuple {
            var attribute: Anytype_Model_Block.Content.Text.Mark.TypeEnum
            var value: String
        }
        
        struct ModelTuple {
            var attribute: MarkStyle
        }
        
        static func asModel(_ tuple: MiddlewareTuple) -> ModelTuple? {
            switch tuple.attribute {
            case .strikethrough: return .init(attribute: .strikethrough(true))
            case .keyboard: return .init(attribute: .keyboard(true))
            case .italic: return .init(attribute: .italic(true))
            case .bold: return .init(attribute: .bold(true))
            case .underscored: return .init(attribute: .underscored(true))
            case .link: return .init(attribute: .link(URLConverter.asModel(tuple.value)))
            case .textColor: return .init(attribute: .textColor(ColorConverter.textColor.asModel(tuple.value)))
            case .backgroundColor: return .init(attribute: .backgroundColor(ColorConverter.backgroundColor.asModel(tuple.value)))
            default: return nil
            }
        }
        static func asMiddleware(_ tuple: ModelTuple) -> MiddlewareTuple {
            switch tuple.attribute {
            case .bold: return .init(attribute: .bold, value: "")
            case .italic: return .init(attribute: .italic, value: "")
            case .keyboard: return .init(attribute: .keyboard, value: "")
            case .strikethrough: return .init(attribute: .strikethrough, value: "")
            case .underscored: return .init(attribute: .underscored, value: "")
            // Add color converter.
            case let .textColor(value): return .init(attribute: .textColor, value: ColorConverter.textColor.asMiddleware(value))
            case let .backgroundColor(value): return .init(attribute: .backgroundColor, value: ColorConverter.backgroundColor.asMiddleware(value))
            
            case let .link(value): return .init(attribute: .link, value: URLConverter.asMiddleware(value))
            }
        }
    }
}

// MARK: Attribute / Helpers
private extension BlockModels.Parser.Text.AttributedText.AttributeConverter {
    enum URLConverter {
        /// Apple BUG!
        /// URL doesn't have .init(string: String).
        /// URL `has` URL?(string: String)
        /// That means that we can't use it as leading-dot notation syntax.
        ///
        static func asModel(_ url: String) -> URL? {
            URL(string: url)
        }
        static func asMiddleware(_ url: URL?) -> String {
            url?.absoluteString ?? ""
        }
    }
    struct ColorConverter {
        typealias Color = BlockModels.Parser.Text.Color
        private var background = false
        static let textColor: Self = .init(background: false)
        static let backgroundColor: Self = .init(background: true)
        func asModel(_ name: String?) -> UIColor {
            Color.Converter.asModel(name, background: background)
        }
        func asMiddleware(_ color: UIColor?) -> String {
            Color.Converter.asMiddleware(color, background: background)
        }
    }
}
