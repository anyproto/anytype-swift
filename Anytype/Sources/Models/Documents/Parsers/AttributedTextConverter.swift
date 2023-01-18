import BlocksModels
import UIKit
import ProtobufMessages
import AnytypeCore

enum AttributedTextConverter {
    
    static func asModel(
        text: String,
        marks: Anytype_Model_Block.Content.Text.Marks,
        style: BlockText.Style
    ) -> UIKitAnytypeText {
        // we need parse marks as if it utf16 string
        let textUTF16 = text.utf16
        // Map attributes to our internal format.
        var markAttributes: [(range: NSRange, markAction: MarkupType)] = marks.marks.compactMap { mark -> (range: NSRange, markAction: MarkupType)? in
            let middlewareTuple = MiddlewareTuple(
                attribute: mark.type,
                value: mark.param
            )
            guard let markValue = MarkStyleActionConverter.asModel(tuple: middlewareTuple) else {
                return nil
            }
            
            // we need convert marks to NSRange
            let textLength = textUTF16.count
            
            let fromOffset: Int? = {
                let from = Int(mark.range.from)
                guard from <= textLength else { return nil }
                return from
            }()
            let toOffset: Int? = {
                let to = Int(mark.range.to)
                guard to <= textLength else { return nil }
                return to
            }()
            
            guard let fromOffset = fromOffset, let toOffset = toOffset else {
                let message = """
                AttributedTextConverter parsing error.
                string: \(text),
                mark range from: \(mark.range.from),
                mark range to: \(mark.range.to),
                mark type: \(mark.type)
                """
                anytypeAssertionFailure(message, domain: .textConverter)
                return nil
            }

            let range = NSRange(location: fromOffset, length: toOffset - fromOffset)
            return (range, markValue)
        }

        let font = style.uiFont
        let anytypeText = UIKitAnytypeText(text: text, style: font, lineBreakModel: .byWordWrapping)

        // We need to separate mention marks from others
        // because mention not only adds attributes to attributed string
        // it will add 1 attachment for icon, so resulting string length will change
        // and other marks range might become broken
        //
        // If we will add mentions after other markup and starting from tail of string
        // it will not break ranges
        var mentionMarks = [(range: NSRange, markAction: MarkupType)]()
        markAttributes.removeAll { (range, markAction) -> Bool in
            if case .mention = markAction {
                mentionMarks.append((range: range, markAction: markAction))
                return true
            }
            return false
        }
        
        mentionMarks.sort { $0.range.location > $1.range.location }
        
        markAttributes.forEach { attribute in
            anytypeText.apply(attribute.markAction, range: attribute.range)
        }
        mentionMarks.forEach {
            anytypeText.apply($0.markAction, range: $0.range)
        }
        
        return anytypeText
    }
    
    static func asMiddleware(attributedText: NSAttributedString) -> MiddlewareString {
        // 1. Iterate over all ranges in a string.
        var marksTuples = [MiddlewareTuple: Set<NSRange>]()
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        // We remove mention attachments to save correct markup ranges
        mutableAttributedText.removeAllMentionAttachmets()
        let wholeText = mutableAttributedText.string
        let wholeStringRange = mutableAttributedText.wholeRange
        mutableAttributedText.enumerateAttributes(in: wholeStringRange) { attributes, range, _ in
            
            // 2. Take all attributes in specific range and convert them to
            let marks = middlewareTuples(from: attributes)
            
            // Discussion:
            // This algorithm uses API and feature of `IndexSet` structure.
            // `IndexSet` combines all ranges into contiguous range if possible and minimizes count of data it keeps.
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
                // 4. If key exists, so, we must add range to result indexSet.
                if var value = marksTuples[mark] {
                    value.insert(range)
                    marksTuples[mark] = value
                }
                // 5. Otherwise, we should init new indexSet from current range.
                else {
                    marksTuples[mark] = [range]
                }
            }
        }

        let middlewareMarks = marksTuples.compactMap { (markup, ranges) -> [Anytype_Model_Block.Content.Text.Mark]? in

            ranges.map { range in
                let middleRange = Anytype_Model_Range(from: Int32(range.lowerBound), to: Int32(range.upperBound))
                return Anytype_Model_Block.Content.Text.Mark(
                    range: middleRange,
                    type: markup.attribute,
                    param: markup.value
                )
            }
        }.flatMap { $0 }
        
        let wholeMarks = Anytype_Model_Block.Content.Text.Marks(marks: middlewareMarks)
        return MiddlewareString(text: wholeText, marks: wholeMarks)
    }
    
    private static func middlewareTuples(from attributes: [NSAttributedString.Key: Any]) -> [MiddlewareTuple] {
        let allMarks = Anytype_Model_Block.Content.Text.Mark.TypeEnum.allCases
        return allMarks.compactMap { mark -> MiddlewareTuple? in
            guard let markValue = middlewareValue(for: mark, from: attributes) else {
                return nil
            }
            return MiddlewareTuple(attribute: mark, value: markValue)
        }
    }
    
    private static func middlewareValue(
        for mark: Anytype_Model_Block.Content.Text.Mark.TypeEnum,
        from attributes: [NSAttributedString.Key: Any]
    ) -> String? {
        switch mark {
        case .bold:
            guard let font = attributes[.font] as? UIFont,
                  font.fontDescriptor.symbolicTraits.contains(.traitBold) else {
                return nil
            }
            return ""
        case .italic:
            guard let font = attributes[.font] as? UIFont,
                  font.fontDescriptor.symbolicTraits.contains(.traitItalic) else {
                return nil
            }
            return ""
        case .keyboard:
            guard let font = attributes[.font] as? UIFont,
                  font.isCode else {
                return nil
            }
            return ""
        case .strikethrough:
            guard let strikethroughValue = attributes[.strikethroughStyle] as? Int,
                  strikethroughValue == NSUnderlineStyle.single.rawValue else {
                return nil
            }
            return ""
        case .underscored:
            guard let underscoredValue = attributes[.anytypeUnderline] as? Bool, underscoredValue else {
                return nil
            }
            return ""
        case .textColor:
            guard let color = attributes[.foregroundColor] as? UIColor,
                  let colorValue = color.middlewareString(background: false) else {
                return nil
            }
            return colorValue
        case .backgroundColor:
            guard let color = attributes[.backgroundColor] as? UIColor,
                  let colorValue = color.middlewareString(background: true) else {
                return nil
            }
            return colorValue
        case .link:
            guard let url = attributes[.link] as? URL else {
                return nil
            }
            return url.absoluteString
        case .mention:
            guard let pageId = attributes[.mention] as? String else {
                return nil
            }
            return pageId
        case .UNRECOGNIZED:
            return nil
        case .emoji:
            return nil
        case .object:
            guard let linkToObject = attributes[.linkToObject] as? String else {
                return nil
            }
            return linkToObject
        }
    }
}
