import BlocksModels
import UIKit
import ProtobufMessages


fileprivate typealias Namespace = MiddlewareModelsModule.Parsers.Text.AttributedText

extension Namespace {
    /// This is Converter between our high-level `NSAttributedString` presentation and low-level middleware String and Marks or `MiddlewareResult` presentation.
    enum Converter {
        struct MiddlewareResult {
            var text: String
            var marks: Anytype_Model_Block.Content.Text.Marks
        }
        
        static func asModel(text: String,
                            marks: Anytype_Model_Block.Content.Text.Marks,
                            style: Anytype_Model_Block.Content.Text.Style) -> NSAttributedString {
            // Map attributes to our internal format.
            var markAttributes = marks.marks.compactMap { value -> (range: NSRange, markStyle: MarkStyle)? in
                guard let markValue = AttributeConverter.asModel(.init(attribute: value.type, value: value.param)) else {
                    return nil
                }
                return (RangeConverter.asModel(value.range), markValue)
            }
            
            // Create modifier of an attributed string.
            let modifier = MarkStyleModifier(attributedText: .init(string: text))

            // We have to set some font, because all styles `change` font attribute.
            // Not the best place to set attribute, however, we don't have best place...
            let defaultFont: UIFont
            if let style = BlockTextContentTypeConverter.asModel(style) {
                defaultFont = UIFont.font(for: style)
            } else {
                defaultFont = .bodyFont
            }
            let range: NSRange = .init(location: 0, length: modifier.attributedString.length)
            modifier.attributedString.addAttribute(.font, value: defaultFont, range: range)
            
            // We need to separate mention marks from others
            // because mention not only adds attributes to attributed string
            // it will add 1 attachment for icon, so resulting string length will change
            // and other marks range might become broken
            //
            // If we will add mentions after other markup and starting from tail of string
            // it will not break ranges
            var mentionMarks = [(range: NSRange, markStyle: MarkStyle)]()
            
            markAttributes.removeAll { (range, markStyle) -> Bool in
                if case .mention = markStyle {
                    mentionMarks.append((range: range, markStyle: markStyle))
                    return true
                }
                return false
            }
            
            mentionMarks.sort { $0.range.location > $1.range.location }
            
            markAttributes.forEach { attribute in
                modifier.applyStyle(style: attribute.markStyle, rangeOrWholeString: .range(attribute.range))
            }
            mentionMarks.forEach {
                modifier.applyStyle(style: $0.markStyle, rangeOrWholeString: .range($0.range))
            }
            
            return modifier.attributedString
        }
        
        static func asMiddleware(attributedText: NSAttributedString) -> MiddlewareResult {
            // 1. Iterate over all ranges in a string.
            var marksStyles: [MarkStyle.HashableKey: NSMutableIndexSet] = [:]
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            // We remove mention attachments to save correct markup ranges
            mutableAttributedText.removeAllMentionAttachmets()
            let wholeText = mutableAttributedText.string
            let wholeStringRange = NSRange(location: 0, length: mutableAttributedText.length)
            mutableAttributedText.enumerateAttributes(in: wholeStringRange, options: []) { (attributes, range, booleanFlag) in
                
                // 2. Take all attributes in specific range and convert them to
                let marks = MarkStyle.from(attributes: attributes)
                
                // Discussion:
                // This algorithm uses API and feature of `IndexSet` structure.
                // `IndexSet` combines all ranges into contigous range if possible and minimizes count of data it keeps.
                // So, instead of enumerate over all ranges and add them, we just add them to current NSIndexSet.
                //
                // Consider following set of ranges:
                //
                // a      b      c
                // 0...5, 5...8, 9...10
                //
                // When we add them to our indexSet, it will keep them in compact form.
                //
                // IndexSet()
                //
                // d      e
                // 0...8, 9...10
                //
                // As you see, `d = a + b, e = c`

                // 3. Iterate over all marks in this range.
                for mark in marks {
                    
                    let key: MarkStyle.HashableKey = .init(markStyle: mark)
                                        
                    // 4. If key exists, so, we must add range to result indexSet.
                    if let value = marksStyles[key] {
                        value.add(in: range)
                    }
                    // 5. Otherwise, we should init new indexSet from current range.
                    else {
                        marksStyles[key] = .init(indexesIn: range)
                    }
                }
            }
            
            // Filter out all cases that are "empty".
            let filteredMarkStyles = marksStyles.filter {
                !MarkStyle.emptyCases.contains($0.0.markStyle)
            }
            
            let middlewareMarks = filteredMarkStyles.compactMap { (tuple) -> [Anytype_Model_Block.Content.Text.Mark]? in
                let (key, value) = tuple
                let type = AttributeConverter.asMiddleware(key.markStyle)

                // For example, return nil if we couldn't convert UIColor to middlware color so
                // all ranges will be skipped for this `mark` value
                guard let markAttribute = type else { return  nil }

                let indexSet: IndexSet = value as IndexSet

                return indexSet.rangeView.enumerated().map {
                    Anytype_Model_Block.Content.Text.Mark(range: RangeConverter.asMiddleware(NSRange($0.element)),
                                                          type: markAttribute.attribute, param: markAttribute.value)
                }
            }.flatMap { $0 }
            
            let wholeMarks: Anytype_Model_Block.Content.Text.Marks = .init(marks: middlewareMarks)
            return .init(text: wholeText, marks: wholeMarks)
        }
    }
}

private extension Namespace.MarkStyle {
    struct HashableKey: Hashable {

        let markStyle: Namespace.MarkStyle

        func hash(into hasher: inout Hasher) {
            hasher.combine(String(describing: markStyle))
        }
    }
}

extension Namespace {
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

// MARK: - Attribute

private extension Namespace {
    enum AttributeConverter {
        struct MiddlewareTuple {
            var attribute: Anytype_Model_Block.Content.Text.Mark.TypeEnum
            var value: String
        }
        
        static func asModel(_ tuple: MiddlewareTuple) -> MarkStyle? {
            switch tuple.attribute {
            case .strikethrough: return .strikethrough(true)
            case .keyboard: return .keyboard(true)
            case .italic: return .italic(true)
            case .bold: return .bold(true)
            case .underscored: return .underscored(true)
            case .link: return .link(URLConverter.asModel(tuple.value))

            case .textColor:
                guard let color = MiddlewareColor(name: tuple.value)?.color(background: false) else {
                    return nil
                }
                return .textColor(color)

            case .backgroundColor:
                guard let color = MiddlewareColor(name: tuple.value)?.color(background: true) else {
                    return nil
                }
                return .backgroundColor(color)
            case .mention:
                return .mention(tuple.value)
            case .UNRECOGNIZED:
                assertionFailure("Unrecognized markup")
                return nil
            }
        }

        static func asMiddleware(_ style: MarkStyle) -> MiddlewareTuple? {
            switch style {
            case .bold: return .init(attribute: .bold, value: "")
            case .italic: return .init(attribute: .italic, value: "")
            case .keyboard: return .init(attribute: .keyboard, value: "")
            case .strikethrough: return .init(attribute: .strikethrough, value: "")
            case .underscored: return .init(attribute: .underscored, value: "")

            case let .textColor(value):
                guard let uiColor = value,
                      let color = MiddlewareColorConverter.asString(uiColor, background: false) else { return nil }
                return .init(attribute: .textColor, value: color)

            case let .backgroundColor(value):
                guard let uiColor = value,
                      let color = MiddlewareColorConverter.asString(uiColor, background: true) else {
                    return nil
                }
                return .init(attribute: .backgroundColor, value: color)

            case let .link(value): return .init(attribute: .link, value: URLConverter.asMiddleware(value))
            case let .mention(pageId):
                guard let pageId = pageId else { return nil }
                return MiddlewareTuple(attribute: .mention, value: pageId)
            }
        }
    }
}

// MARK: - Attribute / Helpers

private extension Namespace.AttributeConverter {
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
}
