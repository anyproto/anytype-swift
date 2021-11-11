import BlocksModels
import UIKit
import FloatingPanel

protocol MarkdownListener {
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData)
}

final class MarkdownListenerImpl: MarkdownListener {
    private let handler: BlockActionHandlerProtocol
    private let markupChanger: BlockMarkupChangerProtocol
    
    init(handler: BlockActionHandlerProtocol, markupChanger: BlockMarkupChangerProtocol) {
        self.handler = handler
        self.markupChanger = markupChanger
    }
    
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData) {
        guard changeType == .typingSymbols else { return }
        
        applyBeginningOfTextShortcuts(data: data)
        applyInlineShortcuts(data: data)
    }
    
    
    private func applyInlineShortcuts(data: TextBlockDelegateData) {
        applyInlineMarkup(.keyboard, triggerSymbol: "`", data: data)
        applyInlineMarkup(.italic, triggerSymbol: "_", data: data)
        applyInlineMarkup(.italic, triggerSymbol: "*", data: data)
        applyInlineMarkup(.bold, triggerSymbol: "__", data: data)
        applyInlineMarkup(.bold, triggerSymbol: "**", data: data)
        applyInlineMarkup(.strikethrough, triggerSymbol: "~~", data: data)
    }
    
    private func applyInlineMarkup(_ markup: MarkupType, triggerSymbol: String, data: TextBlockDelegateData) {
        guard var textBeforeCaret = data.textView.textBeforeCaret else { return }
        guard let caretPosition = data.textView.caretPosition else { return }
        
        if textBeforeCaret.hasSuffix(triggerSymbol) {
            textBeforeCaret.removeLast(triggerSymbol.count) // Removed closing symbol
            
            let reversedTextBeforeCaret = String(textBeforeCaret.reversed()) // looking for closest symbol
            
            if let rangeOfTrigger = reversedTextBeforeCaret.range(of: triggerSymbol) {
                guard canApplyItalic(triggerSymbol: triggerSymbol, rangeOfTrigger: rangeOfTrigger, reversedTextBeforeCaret: reversedTextBeforeCaret) else { return }
                
                let lengthOfText = reversedTextBeforeCaret
                    .distanceFromTheBegining(to: rangeOfTrigger.lowerBound)
                
                let locationOfClosingSymbol = data.textView.offsetFromBegining(caretPosition) - triggerSymbol.count
                let locationOfOpeningSymbol = locationOfClosingSymbol - lengthOfText
                let range = NSRange(location: locationOfOpeningSymbol, length: lengthOfText)
                
                guard let newText = markupChanger
                        .toggleMarkup(markup, blockId: data.info.id, range: range)?.mutable else { return }
                
                let rangeOfClosingSymbol = NSRange(location: locationOfClosingSymbol, length: triggerSymbol.count)
                newText.mutableString.deleteCharacters(in: rangeOfClosingSymbol)
                let rangeOfOpeningSymbol = NSRange(location: locationOfOpeningSymbol - triggerSymbol.count, length: triggerSymbol.count)
                newText.mutableString.deleteCharacters(in: rangeOfOpeningSymbol)
                
                handler.changeText(newText, info: data.info)
                let cursorLocation = locationOfClosingSymbol - (triggerSymbol.count)
                handler.changeCaretPosition(range: NSRange(location: cursorLocation, length: 0))
            }
        }
    }
    
    private func canApplyItalic(triggerSymbol: String, rangeOfTrigger: Range<String.Index>, reversedTextBeforeCaret: String) -> Bool {
        guard triggerSymbol == "*" || triggerSymbol == "_" else { return true }

        let boldTriggerSymbol = triggerSymbol + triggerSymbol
        
        guard let boldRange = reversedTextBeforeCaret.range(of: boldTriggerSymbol) else { return true }
        
        let italicDistance = reversedTextBeforeCaret
            .distanceFromTheBegining(to: rangeOfTrigger.lowerBound)
        let boldDistance = reversedTextBeforeCaret
            .distanceFromTheBegining(to: boldRange.lowerBound)
        
        return italicDistance < boldDistance
    }
    
    private func applyBeginningOfTextShortcuts(data: TextBlockDelegateData) {
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
        
        handler.turnInto(style, blockId: data.info.id)
        
        let text = data.textView.attributedText.mutable
        text.mutableString.deleteCharacters(in: NSMakeRange(0, commandLength))
        handler.changeText(text, info: data.info)
    }
    
}
