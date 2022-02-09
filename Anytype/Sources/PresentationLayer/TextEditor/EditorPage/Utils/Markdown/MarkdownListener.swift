import BlocksModels
import UIKit
import FloatingPanel
import AnytypeCore

protocol MarkdownListener {
    func textDidChange(changeType: TextChangeType, data: TextBlockDelegateData)
//    func shouldPerformMarkdownChange(changeType: TextChangeType, data: TextBlockDelegateData) -> Bool
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

    // MARK: - Inline
    private func applyInlineShortcuts(data: TextBlockDelegateData) {
        InlineMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                applyInlineMarkup(shortcut.markup, triggerSymbol: text, data: data)
            }
        }
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
                
                guard lengthOfText > 0 else { return }
                
                let locationOfClosingSymbol = data.textView.offsetFromBegining(caretPosition) - triggerSymbol.count
                let locationOfOpeningSymbol = locationOfClosingSymbol - lengthOfText
                let range = NSRange(location: locationOfOpeningSymbol, length: lengthOfText)
                
                guard let newText = markupChanger
                        .setMarkup(markup, blockId: data.info.id, range: range)?.mutable else {
                            anytypeAssertionFailure(
                                "Could not apply markup \(markup) for \(data.info)",
                                domain: .markdownListener
                            )
                            return
                        }
                
                let rangeOfClosingSymbol = NSRange(location: locationOfClosingSymbol, length: triggerSymbol.count)
                newText.mutableString.deleteCharacters(in: rangeOfClosingSymbol)
                let rangeOfOpeningSymbol = NSRange(location: locationOfOpeningSymbol - triggerSymbol.count, length: triggerSymbol.count)
                newText.mutableString.deleteCharacters(in: rangeOfOpeningSymbol)
                
                handler.changeTextForced(newText, blockId: data.info.id)
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
    
    // MARK: - BeginningOfText
    private func applyBeginningOfTextShortcuts(data: TextBlockDelegateData) {
        BeginingOfTextMarkdown.all.forEach { shortcut in
            shortcut.text.forEach { text in
                if beginingOfTextHaveShortcutAndCarretInsideIt(text, data: data) {
                    applyStyle(shortcut.style, data: data, commandLength: text.count)
                }
            }
        }
    }
    
    private func beginingOfTextHaveShortcutAndCarretInsideIt(_ shortcut: String, data: TextBlockDelegateData) -> Bool {
        guard let offsetToCaretPosition = data.textView.offsetToCaretPosition() else {
            anytypeAssertionFailure("No caret position for markdown call", domain: .markdownListener)
            return false
        }
        
        return data.textView.text.hasPrefix(shortcut) && shortcut.count >= offsetToCaretPosition
    }

    
    private func applyStyle(_ style: BlockText.Style, data: TextBlockDelegateData, commandLength: Int) {
        guard case let .text(textContent) = data.info.content else { return }
        guard textContent.contentType != style else { return }
        guard BlockRestrictionsBuilder.build(content:  data.info.content).canApplyTextStyle(style) else { return }
        
        handler.turnInto(style, blockId: data.info.id)
        
        let text = data.textView.attributedText.mutable
        text.mutableString.deleteCharacters(in: NSMakeRange(0, commandLength))
        handler.changeTextForced(text, blockId: data.info.id)
    }
}
