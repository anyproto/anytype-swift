import UIKit

enum TextTriggerSymbols {
    static let slashMenu = "/"
    
    static func mention(prependSpace: Bool) -> String {
        return prependSpaceSymbolIfNeeded("@", prepend: prependSpace)
    }
    
    private static func prependSpaceSymbolIfNeeded(_ symbol: String, prepend: Bool) -> String {
        if prepend {
            return " \(symbol)"
        } else {
            return symbol
        }
    }
}
