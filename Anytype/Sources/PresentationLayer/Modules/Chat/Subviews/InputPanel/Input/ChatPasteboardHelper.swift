import Foundation
import Factory
import UIKit

protocol ChatPasteboardHelperProtocol: AnyObject {
    func attributedString() -> NSAttributedString?
}

final class ChatPasteboardHelper: ChatPasteboardHelperProtocol {
    
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    @Injected(\.chatInputLinkParser)
    private var chatInputLinkParser: any ChatInputLinkParserProtocol
    
    func attributedString() -> NSAttributedString? {
        if let string = pasteboardHelper.obtainAttributedString() {
            return parseAttributedString(string)
        } else if let url = pasteboardHelper.obtainUrlSlot() {
            return parseUrl(url)
        } else if let string = pasteboardHelper.obtainString() {
            let atrsString = NSAttributedString(string: string)
            return parseAttributedString(atrsString)
        }
        return nil
    }
    
    private func parseAttributedString(_ string: NSAttributedString) -> NSAttributedString? {
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
        
        let links = chatInputLinkParser.handlePaste(text: newString.string)
        for link in links {
            switch link {
            case .addLinkStyle(let range, let link):
                let containsLink = newString.containsNotNilAttribute(.chatLinkToURL, in: range)
                if !containsLink {
                    newString.addAttribute(.chatLinkToURL, value: link, range: range)
                }
            }
        }
        
        return newString
    }
    
    private func parseUrl(_ url: URL) -> NSAttributedString {
        let string = NSMutableAttributedString(string: url.absoluteString)
        string.addAttribute(.chatLinkToURL, value: url, range: string.wholeRange)
        return string
    }
}

extension Container {
    var chatPasteboardHelper: Factory<any ChatPasteboardHelperProtocol> {
        self { ChatPasteboardHelper() }
    }
}
