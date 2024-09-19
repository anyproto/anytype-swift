import Foundation
import UIKit
import SwiftUI
import Services

final class DiscussionTextViewCoordinator: NSObject, UITextViewDelegate, NSTextContentStorageDelegate {
    
    private enum Mode {
        case text
        case mention
    }
    
    @Binding private var text: NSAttributedString
    @Binding private var editing: Bool
    @Binding private var mention: DiscussionTextMention
    @Binding private var height: CGFloat
    
    private let maxHeight: CGFloat
    private let markdownListener: any MarkdownListener
    private let font: AnytypeFont
    private let codeFont: AnytypeFont
    
    // MARK: - State
    private var mode: Mode = .text
    private var triggerSymbolPosition: UITextPosition?
    
    init(
        text: Binding<NSAttributedString>,
        editing: Binding<Bool>,
        mention: Binding<DiscussionTextMention>,
        height: Binding<CGFloat>,
        maxHeight: CGFloat,
        font: AnytypeFont, // TODO: rename to fontStyle
        codeFont: AnytypeFont
    ) {
        self._text = text
        self._editing = editing
        self._mention = mention
        self._height = height
        self.maxHeight = maxHeight
        self.font = font
        self.codeFont = codeFont
        self.markdownListener = MarkdownListenerImpl(internalListeners: [InlineMarkdownListener()])
        
        super.init()
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
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let change = markdownListener.markdownChange(textView: textView, replacementText: text, range: range)
        
        switch change {
        case .turnInto, .addBlock, nil:
            // Doesn't support
            return true
        case .addStyle(let markupType, let text, let range, let focusRange):
            return addStyle(textView: textView, type: markupType, text: text, range: range, focusRange: focusRange, removeAttribute: false)
        }
    }
    
    // MARK: - Private
    
    private func addStyle(textView: UITextView, type: MarkupType, text: NSAttributedString, range: NSRange, focusRange: NSRange, removeAttribute: Bool) -> Bool {
        
        let mutableText = text.mutable
        
        switch type {
        case .bold, .italic, .keyboard, .strikethrough, .underscored:
            guard let attributedKey = type.discussionAttributedKeyWithoutValue else { return true }
            if removeAttribute {
                mutableText.removeAttribute(attributedKey, range: range)
            } else {
                mutableText.addAttributes([attributedKey: true], range: range)
            }
//            let updatedText = updateStyles(text: mutableText)
            textView.textStorage.setAttributedString(mutableText)
            textView.selectedRange = focusRange
            return false
        case .textColor, .backgroundColor:
            // Doesn't support
            break
        case .link(let uRL):
            // TODO: Implement it
            print("link doesn't implemented")
        case .linkToObject(let string):
            // TODO: Implement it
            print("linkToObject doesn't implemented")
        case .mention(let mentionObject):
            // TODO: Implement it
            print("mention doesn't implemented")
        case .emoji(let emoji):
            // TODO: Implement it
            print("emoji doesn't implemented")
        }
        return true
    }
    
//    func updateStyles(text: NSAttributedString) -> NSAttributedString {
//        let newText = text.mutable
//        text.enumerateAttributes(in: NSRange(location: 0, length: text.length)) { attrs, range, _ in
//            
//            var newFont = UIKitFontBuilder.uiKitFont(font: font)
//            
//            if attrs[.discussionBold] != nil {
//                newFont = newFont.bold
//            }
//            
//            if attrs[.discussionItalic] != nil {
//                newFont = newFont.italic
//            }
//            
//            if attrs[.discussionKeyboard] != nil {
//                newFont = UIKitFontBuilder.uiKitFont(font: codeFont)
//            }
//            
//            if attrs[.discussionStrikethrough] != nil {
//                newText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
//            } else {
//                newText.removeAttribute(.strikethroughStyle, range: range)
//            }
//            
//            var underlineStyle: NSUnderlineStyle? = nil
//            
//            if attrs[.discussionUnderscored] != nil {
//                underlineStyle = .single
//            }
//            
//            if attrs[.discussionMention] != nil {
//                newText.addAttribute(.anytypeNotEditable, value: true, range: range)
//                underlineStyle = .single
//            } else {
//                newText.addAttribute(.anytypeNotEditable, value: false, range: range)
//            }
//            
//            if let underlineStyle {
//                newText.addAttribute(.underlineStyle, value: underlineStyle, range: range)
//                newText.addAttribute(.underlineColor, value: UIColor.Text.primary, range: range)
//            } else {
//                newText.removeAttribute(.underlineStyle, range: range)
//            }
//            
//            newText.addAttribute(.font, value: newFont, range: range)
//        }
//        
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.lineHeightMultiple = font.lineHeightMultiple
//        
//        newText.addAttribute(.kern, value: font.config.kern, range: NSRange(location: 0, length: newText.length))
//        newText.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: newText.length))
//        
//        return newText
//    }
    
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard range.length > 0 else { return nil }
    
        let discussionMenuKeys = NSAttributedString.Key.discussionMenuKeys
        let menuItems = discussionMenuKeys.compactMap { makeMenuAction(textView, editMenuForTextIn: range, attributed: $0) }
        return UIMenu(children: menuItems + suggestedActions)
    }
    
    // MARK: -
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        
        let newText = originalText.mutable
        originalText.enumerateAttributes(in: NSRange(location: 0, length: originalText.length)) { attrs, range, _ in
            
            var newFont = UIKitFontBuilder.uiKitFont(font: font)
            
            if attrs[.discussionBold] != nil {
                newFont = newFont.bold
            }
            
            if attrs[.discussionItalic] != nil {
                newFont = newFont.italic
            }
            
            if attrs[.discussionKeyboard] != nil {
                newFont = UIKitFontBuilder.uiKitFont(font: codeFont)
            }
            
            if attrs[.discussionStrikethrough] != nil {
                newText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            } else {
                newText.removeAttribute(.strikethroughStyle, range: range)
            }
            
            var underlineStyle: NSUnderlineStyle? = nil
            
            if attrs[.discussionUnderscored] != nil {
                underlineStyle = .single
            }
            
            if attrs[.discussionMention] != nil {
//                newText.addAttribute(.anytypeNotEditable, value: true, range: range)
                underlineStyle = .single
            } else {
//                newText.addAttribute(.anytypeNotEditable, value: false, range: range)
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
        paragraph.lineHeightMultiple = font.lineHeightMultiple
        
        newText.addAttribute(.kern, value: font.config.kern, range: NSRange(location: 0, length: newText.length))
        newText.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: newText.length))
        
        return NSTextParagraph(attributedString: newText)
    }
    
    private func makeMenuAction(_ textView: UITextView, editMenuForTextIn range: NSRange, attributed: NSAttributedString.Key) -> UIMenuElement? {
        guard let info = attributed.discussionMenuItemInfo() else { return nil }
        
        let containsNoStyle = textView.attributedText.containsNilAttribute(attributed, in: range)
        return UIAction(title: containsNoStyle ? info.markText : info.unmarkText) { [weak self] _ in
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
}
