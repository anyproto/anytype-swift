import UIKit

enum TextTriggerSymbols {
    static func slashMenu(textView: UITextView) -> String {
        return prependSpaceSymbolIfNeeded("/", textView: textView)
    }
    
    static func mention(textView: UITextView) -> String {
        return prependSpaceSymbolIfNeeded("@", textView: textView)
    }
    
    private static func prependSpaceSymbolIfNeeded(_ symbol: String, textView: UITextView) -> String {
        if textView.isCarretInTheBeginingOfDocument {
            return symbol
        } else {
            return " \(symbol)"
        }
    }
}
