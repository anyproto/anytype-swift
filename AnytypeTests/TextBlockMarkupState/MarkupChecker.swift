@testable import Anytype
import UIKit

final class MarkupChecker {
    
    private let markupType: BlockHandlerActionType.TextAttributesType
    private let attributedStringBlueprint: [(NSRange, Any?)]
    let exampleString: NSAttributedString
    let wholeStringWithMarkup: NSAttributedString
    
    init(
        markupType: BlockHandlerActionType.TextAttributesType,
        attributedStringBlueprint: [(NSRange, Any?)]
    ) {
        self.markupType = markupType
        self.attributedStringBlueprint = attributedStringBlueprint
        
        let result = NSMutableAttributedString()
        
        attributedStringBlueprint.forEach { range, value in
            let string = Array(repeating: "a", count: range.length).joined()
            result.append(NSAttributedString(string: string))
            if let value = value {
                result.addAttribute(markupType.attributedStringKey, value: value, range: range)
            }
        }
        exampleString = NSAttributedString(attributedString: result)
        
        wholeStringWithMarkup = NSAttributedString(
            string: "aaaaaaaaaaaaaaaa",
            attributes: [markupType.attributedStringKey: markupType.matchingAttribute]
        )
    }
    
    func checkMarkup(in range: NSRange) -> Bool {
        switch markupType {
        case .bold:
            return exampleString.isFontInWhole(range: range, has: .traitBold)
        case .italic:
            return exampleString.isFontInWhole(range: range, has: .traitItalic)
        case .keyboard:
            return exampleString.isCodeFontInWhole(range: range)
        case .strikethrough:
            return exampleString.isEverySymbol(in: range, has: .strikethroughStyle)
        }
    }
    
    func checkWholeStringWithMarkup(in range: NSRange) -> Bool {
        switch markupType {
        case .bold:
            return wholeStringWithMarkup.isFontInWhole(range: range, has: .traitBold)
        case .italic:
            return wholeStringWithMarkup.isFontInWhole(range: range, has: .traitItalic)
        case .keyboard:
            return wholeStringWithMarkup.isCodeFontInWhole(range: range)
        case .strikethrough:
            return wholeStringWithMarkup.isEverySymbol(in: range, has: .strikethroughStyle)
        }
    }
}
