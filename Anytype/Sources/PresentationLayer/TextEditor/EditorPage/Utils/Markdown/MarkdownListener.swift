import BlocksModels
import UIKit
import FloatingPanel

protocol MarkdownListener {
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData)
}

final class MarkdownListenerImpl: MarkdownListener {
    private let handler: BlockActionHandlerProtocol
    
    init(handler: BlockActionHandlerProtocol) {
        self.handler = handler
    }
    
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData) {
        guard changeType == .typingSymbols else { return }
        
        onTextChange(data: data)
    }
    
    private func onTextChange(data: TextBlockDelegateData) {
        guard let textBeforeCaret = data.textView.textBeforeCaret else { return }
        
        switch textBeforeCaret {
        case "# ":
            applyStyle(.header, data: data, commandLength: textBeforeCaret.count)
        case "## ":
            applyStyle(.header2, data: data, commandLength: textBeforeCaret.count)
        case "### ":
            applyStyle(.header3, data: data, commandLength: textBeforeCaret.count)
        case "\" ", "\' ", "“ ", "‘ ":
            applyStyle(.quote, data: data, commandLength: textBeforeCaret.count)
        case "* ", "- ", "+ ":
            applyStyle(.bulleted, data: data, commandLength: textBeforeCaret.count)
        case "[] ":
            applyStyle(.checkbox, data: data, commandLength: textBeforeCaret.count)
        case "1. ":
            applyStyle(.numbered, data: data, commandLength: textBeforeCaret.count)
        case "> ":
            applyStyle(.toggle, data: data, commandLength: textBeforeCaret.count)
        case "``` ":
            applyStyle(.code, data: data, commandLength: textBeforeCaret.count)
        default:
            break
        }
    }
    
    private func applyStyle(_ style: BlockText.Style, data: TextBlockDelegateData, commandLength: Int) {
        guard case let .text(textContent) = data.info.content else { return }
        guard textContent.contentType != style else { return }
        guard BlockRestrictionsBuilder.build(content:  data.info.content).canApplyTextStyle(style) else { return }
        
        handler.turnInto(blockId: data.info.id, style: style)
        
        let text = data.textView.attributedText.mutable
        text.mutableString.deleteCharacters(in: NSMakeRange(0, commandLength))
        handler.changeText(text, info: data.info)
    }
    
}
