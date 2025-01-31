import Foundation
import Factory

final class ChatPasteboardHelper {
    
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    
    func attributedString() -> NSAttributedString? {
        let string = pasteboardHelper.obtainAttributedString()
        return string
    }
}
