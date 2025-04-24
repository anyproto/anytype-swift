import Foundation
import UniformTypeIdentifiers
import UIKit
import SwiftUI
import Services

final class ChatTextViewCoordinator: NSObject, UITextViewDelegate, NSTextContentStorageDelegate, AnytypeUITextViewDelegate {
    
    private enum Mode {
        case text
        case mention
    }
    
    @Binding private var text: NSAttributedString
    @Binding private var editing: Bool
    @Binding private var mention: ChatTextMention
    @Binding private var height: CGFloat
    
    private let maxHeight: CGFloat
    private let markdownListener: any MarkdownListener
    private let anytypeFont: AnytypeFont
    private let anytypeCodeFont: AnytypeFont
    
    var linkTo: ((_ range: NSRange) -> Void)?
    var linkParsed: ((_ url: URL) -> Void)?
    var pasteAttachmentsFromBuffer: ((_ items: [NSItemProvider]) -> Void)?
    var defaultTypingAttributes: [NSAttributedString.Key : Any] = [:]
    
    // MARK: - State
    private var mode: Mode = .text
    private var triggerSymbolPosition: UITextPosition?
    private var lastApplyedEditingState: Bool?
    @Injected(\.chatPasteboardHelper)
    private var chatPasteboardHelper: any ChatPasteboardHelperProtocol
    @Injected(\.chatInputLinkParser)
    private var chatInputLinkParser: any ChatInputLinkParserProtocol
    
    init(
        text: Binding<NSAttributedString>,
        editing: Binding<Bool>,
        mention: Binding<ChatTextMention>,
        height: Binding<CGFloat>,
        maxHeight: CGFloat,
        anytypeFont: AnytypeFont,
        anytypeCodeFont: AnytypeFont
    ) {
        self._text = text
        self._editing = editing
        self._mention = mention
        self._height = height
        self.maxHeight = maxHeight
        self.anytypeFont = anytypeFont
        self.anytypeCodeFont = anytypeCodeFont
        self.markdownListener = MarkdownListenerImpl(internalListeners: [InlineMarkdownListener()])
        
        super.init()
    }
    
    func changeEditingStateIfNeeded(textView: UITextView, editing: Bool) {
        if editing, lastApplyedEditingState != true {
            if !textView.isFirstResponder {
                textView.becomeFirstResponder()
            }
            lastApplyedEditingState = true
        } else if !editing, lastApplyedEditingState != false {
            if textView.isFirstResponder {
                textView.resignFirstResponder()
            }
            lastApplyedEditingState = false
        }
    }
    
    func updateTextIfNeeded(textView: UITextView, string: NSAttributedString) {
        guard textView.attributedText != string else { return }
        
        let oldSelectedRange = textView.selectedRange
        let oldAttributedString = textView.attributedText
        let oldTextBeforeCarret = textView.textBeforeCaret
        
        textView.attributedText = string
        
        if textView.attributedText.string.isEmpty {
            textView.typingAttributes = defaultTypingAttributes
        }
        
        if editing {
            // Save carret position
            if textView.textBeforeCaret != oldTextBeforeCarret {
                let diffLocation = string.length - (oldAttributedString?.length ?? 0)
                textView.selectedRange = NSRange(
                    location: oldSelectedRange.location + diffLocation,
                    length: 0
                )
            } else {
                textView.selectedRange = oldSelectedRange
            }
        }
        
        mode = .text
        mention = .finish
        updateHeight(textView: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !editing {
            editing = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if editing {
            editing = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        updateHeight(textView: textView)
        
        if let textBeforeCaret = textView.textBeforeCaret,
           let caretPosition = textView.caretPosition {
            
            let carretOffset = textView.offsetFromBegining(caretPosition)
            
            if textBeforeCaret.hasSuffix(TextTriggerSymbols.mention(prependSpace: carretOffset > 1)) {
                mode = .mention
                triggerSymbolPosition = textView.caretPosition
            }
        }
        
        switch mode {
        case .text:
            break // We save text in any mode
        case .mention:
            if let searchText = mentionText(textView: textView),
               let triggerSymbolPosition,
               let caretPosition = textView.caretPosition,
               let startPosition = textView.position(from: triggerSymbolPosition, offset: -1) {
                
                let location = textView.offsetFromBegining(startPosition)
                let lenght = textView.offset(from: startPosition, to: caretPosition)
                mention = .search(searchText, NSRange(location: location, length: lenght))
                
                if isTriggerSymbolDeleted(textView: textView) || searchText.count(where: { $0 == " " }) > 1 {
                    mode = .text
                    mention = .finish
                }
            }
        }
        
        text = textView.attributedText
        
        if textView.attributedText.string.isEmpty {
            textView.typingAttributes = defaultTypingAttributes
        }
        
        if let selectedRange = textView.selectedTextRange {
            var cursorRect = textView.caretRect(for: selectedRange.end)
            cursorRect.origin.y += textView.textContainerInset.bottom
            textView.scrollRectToVisible(cursorRect, animated: true)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let change = markdownListener.markdownChange(textView: textView, replacementText: text, range: range)
        
        switch change {
        case .turnInto, .addBlock, nil:
            // Doesn't support
            break
        case .addStyle(let markupType, let text, let range, let focusRange):
            let result = addStyle(textView: textView, type: markupType, text: text, range: range, focusRange: focusRange, removeAttribute: false)
            if !result {
                textViewDidChange(textView)
            }
            return result
        }
        
        handleLinkInput(textView: textView, shouldChangeTextIn: range, replacementText: text)
        
        return true
    }
    
    // MARK: - AnytypeUITextViewDelegate
    
    func textViewPasteAction(_ textView: AnytypeUITextView, sender: Any?) {
        
        if let pasteStr = chatPasteboardHelper.attributedString() {
            let newStr = NSMutableAttributedString(attributedString: textView.attributedText)
            let newSelectedRange = NSRange(location: textView.selectedRange.location + pasteStr.length, length: 0)
            newStr.replaceCharacters(in: textView.selectedRange, with: pasteStr)
            textView.attributedText = newStr
            textView.selectedRange = newSelectedRange
            textViewDidChange(textView)
            
            var links: [URL] = []
            pasteStr.enumerateAttribute(.chatLinkToURL, in: pasteStr.wholeRange) { attr, _, _ in
                if let link = attr as? URL {
                    links.append(link)
                }
            }
            
            for link in links {
                linkParsed?(link)
            }
        }
        
        let attachments = chatPasteboardHelper.attachments()
        if attachments.isNotEmpty {
            pasteAttachmentsFromBuffer?(attachments)
        }
    }
    
    func textViewHasPasteAction(_ textView: AnytypeUITextView) -> Bool {
        return UIPasteboard.general.hasSlots
    }
    
    // MARK: - Private
    
    private func addStyle(textView: UITextView, type: MarkupType, text: NSAttributedString, range: NSRange, focusRange: NSRange, removeAttribute: Bool) -> Bool {
        
        let mutableText = text.mutable
        
        switch type {
        case .bold, .italic, .keyboard, .strikethrough, .underscored:
            guard let attributedKey = type.chatAttributedKeyWithoutValue else { return true }
            if removeAttribute {
                mutableText.removeAttribute(attributedKey, range: range)
            } else {
                mutableText.addAttributes([attributedKey: true], range: range)
            }
            textView.textStorage.setAttributedString(mutableText)
            textView.selectedRange = focusRange
            return false
        case .textColor, .backgroundColor:
            // Doesn't support
            break
        case .mention, .emoji, .link, .linkToObject:
            // Doesn't support in markdownListener
            break
        }
        return true
    }
    
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard range.length > 0 else { return nil }
    
        let chatMenuKeys = NSAttributedString.Key.chatToggleMenuKeys
        let toggleMenuItems = chatMenuKeys.compactMap { makeToggleMenuAction(textView, editMenuForTextIn: range, attributed: $0) }
        let format = UIMenu(title: Loc.format, children: toggleMenuItems)
        
        let linkToAction = UIAction(title: Loc.link) { [linkTo] _ in
            linkTo?(range)
        }
        
        let standardEdit = suggestedActions.first { ($0 as? UIMenu)?.identifier == .standardEdit }
        let otherActions = suggestedActions.filter { ($0 as? UIMenu)?.identifier != .standardEdit }
        
        let actions = [standardEdit, format, linkToAction].compactMap { $0 } + otherActions
        
        return UIMenu(children: actions)
    }
    
    // MARK: -
    
    nonisolated func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        
        let newText = originalText.mutable
        originalText.enumerateAttributes(in: NSRange(location: 0, length: originalText.length)) { attrs, range, _ in
            
            var newFont = UIKitFontBuilder.uiKitFont(font: anytypeFont)
            
            if attrs[.chatBold] != nil {
                newFont = newFont.bold
            }
            
            if attrs[.chatItalic] != nil {
                newFont = newFont.italic
            }
            
            if attrs[.chatKeyboard] != nil {
                newFont = UIKitFontBuilder.uiKitFont(font: anytypeCodeFont)
            }
            
            if attrs[.chatStrikethrough] != nil {
                newText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            } else {
                newText.removeAttribute(.strikethroughStyle, range: range)
            }
            
            var underlineStyle: NSUnderlineStyle? = nil
            
            if attrs[.chatUnderscored] != nil {
                underlineStyle = .single
            }
            
            if attrs[.chatMention] != nil {
                underlineStyle = .single
            }
            
            if attrs[.chatLinkToURL] != nil {
                underlineStyle = .single
            }
            
            if attrs[.chatLinkToObject] != nil {
                underlineStyle = .single
            }
            
            if let underlineStyle {
                newText.addAttribute(.underlineStyle, value: underlineStyle.rawValue, range: range)
                newText.addAttribute(.underlineColor, value: UIColor.Text.primary, range: range)
            } else {
                newText.removeAttribute(.underlineStyle, range: range)
            }
            
            newText.addAttribute(.font, value: newFont, range: range)
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = anytypeFont.lineHeightMultiple
        
        newText.addAttribute(.kern, value: anytypeFont.config.kern, range: NSRange(location: 0, length: newText.length))
        newText.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: newText.length))
        newText.addAttribute(.foregroundColor, value: UIColor.Text.primary, range: NSRange(location: 0, length: newText.length))
        
        return NSTextParagraph(attributedString: newText)
    }
    
    private func makeToggleMenuAction(_ textView: UITextView, editMenuForTextIn range: NSRange, attributed: NSAttributedString.Key) -> UIMenuElement? {
        guard let info = attributed.chatToggleMenuItemInfo() else { return nil }
        
        let containsNoStyle = textView.attributedText.containsNilAttribute(attributed, in: range)
        return UIAction(image: UIImage(asset: info.icon)) { [weak self] _ in
            _ = self?.addStyle(
                textView: textView,
                type: info.markupType,
                text: textView.attributedText,
                range: range,
                focusRange: range,
                removeAttribute: !containsNoStyle
            )
            
            self?.text = textView.attributedText
        }
    }
    
    private func mentionText(textView: UITextView) -> String? {
        guard let caretPosition = textView.caretPosition,
              let triggerSymbolPosition = triggerSymbolPosition,
              let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) else {
            return nil
        }
        return textView.text(in: range)
    }
    
    private func isTriggerSymbolDeleted(textView: UITextView) -> Bool {
        guard let triggerSymbolPosition = triggerSymbolPosition,
              let caretPosition = textView.caretPosition else {
            return false
        }

        return textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending
    }
    
    private func updateHeight(textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .infinity))
        var newHeight: CGFloat
        
        if size.height > maxHeight {
            textView.isScrollEnabled = true
            newHeight = maxHeight
        } else {
            textView.isScrollEnabled = false
            newHeight = size.height
        }
        
        if newHeight != height {
            height = newHeight
        }
    }
    
    private func handleLinkInput(textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        let linkChange = chatInputLinkParser.handleInput(sourceText: textView.attributedText, range: range, replacementText: text)
        
        switch linkChange {
        case .addLinkStyle(let range, let link):
            let containsLink = textView.textStorage.containsNotNilAttribute(.chatLinkToURL, in: range)
            if !containsLink {
                textView.textStorage.addAttribute(.chatLinkToURL, value: link, range: range)
                textViewDidChange(textView)
                linkParsed?(link)
            }
        case nil:
            break
        }
    }
}
