import BlocksModels
import UIKit

protocol MarkdownListener {
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData)
}

final class MarkdownListenerImpl: MarkdownListener {
    private let handler: EditorActionHandlerProtocol
    
    init(handler: EditorActionHandlerProtocol) {
        self.handler = handler
    }
    
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData) {
        guard changeType == .typingSymbols else { return }
        
        onTextChange(data: data)
    }
    
    private func onTextChange(data: TextBlockDelegateData) {
        // TODO
    }

}
