import Foundation
import Services

extension URL {
    var attributedString: NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(string: absoluteString)
        let newRange = mutableAttributedString.wholeRange
        let modifier = MarkStyleModifier(
            attributedString: mutableAttributedString,
            anytypeFont: .uxBodyRegular
        )
        modifier.apply(.link(self), shouldApplyMarkup: true, range: newRange)
        
        return NSAttributedString(attributedString: modifier.attributedString)
    }
}
