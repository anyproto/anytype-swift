import Foundation
import Factory
import UIKit

protocol ChatPasteboardHelperProtocol: AnyObject {
    func attributedString() -> NSAttributedString?
}

final class ChatPasteboardHelper: ChatPasteboardHelperProtocol {
    
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    
    func attributedString() -> NSAttributedString? {
        guard let string = pasteboardHelper.obtainAttributedString() else { return nil }
        let newString = NSMutableAttributedString(string: string.string)
        
        string.enumerateAttributes(in: NSRange(location: 0, length: string.length)) { attrs, range, _ in
            
            if let font = attrs[.font] as? UIFont {
                if font.isBold {
                    newString.addAttribute(.chatBold, value: true, range: range)
                }
                if font.isItalic {
                    newString.addAttribute(.chatItalic, value: true, range: range)
                }
            }
            
            if attrs[.strikethroughStyle] != nil {
                newString.addAttribute(.chatStrikethrough, value: true, range: range)
            }
            
            if attrs[.underlineStyle] != nil {
                newString.addAttribute(.chatUnderscored, value: true, range: range)
            }
            
            if let url = attrs[.link] as? URL {
                newString.addAttribute(.chatLinkToURL, value: url, range: range)
            }
        }
        
        return newString
    }
}

extension Container {
    var chatPasteboardHelper: Factory<any ChatPasteboardHelperProtocol> {
        self { ChatPasteboardHelper() }
    }
}
