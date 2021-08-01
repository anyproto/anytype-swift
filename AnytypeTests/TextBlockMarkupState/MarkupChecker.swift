@testable import Anytype
import UIKit

final class MarkupChecker {
    
    private let markupType: MarkupType
    private let attributedStringBlueprint: [(NSRange, Any?)]
    let exampleString: NSAttributedString
    
    init(
        markupType: MarkupType,
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
    }
    
    func checkMarkup(in range: NSRange) -> Bool {
        switch markupType {
        case .bold:
            return exampleString.fontInWhole(range: range, has: .traitBold)
        case .italic:
            return exampleString.fontInWhole(range: range, has: .traitItalic)
        case .code:
            return exampleString.fontIsCodeInWhole(range: range)
        case .strikethrough:
            return exampleString.everySymbol(in: range, has: .strikethroughStyle)
        }
    }
}
