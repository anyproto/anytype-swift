import Foundation
import UIKit
import SwiftUI
import Services

final class DiscussionTextViewCoordinator: NSObject, UITextViewDelegate {
    
    @Binding private var editing: Bool
    @Binding private var height: CGFloat
    
    private let maxHeight: CGFloat
    private let markdownListener: MarkdownListener
    private let font: UIFont
    private let codeFont: UIFont
    
    init(editing: Binding<Bool>, height: Binding<CGFloat>, maxHeight: CGFloat, font: UIFont, codeFont: UIFont) {
        self._editing = editing
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
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let change = markdownListener.markdownChange(textView: textView, replacementText: text, range: range)
        
        switch change {
        case .turnInto, .addBlock, nil:
            // Doesn't support
            return true
        case .addStyle(let markupType, let text, let range, let focusRange):
            return addStyle(textView: textView, type: markupType, text: text, range: range, focusRange: focusRange)
        }
    }
        
    // MARK: - Private
    
    func addStyle(textView: UITextView, type: MarkupType, text: NSAttributedString, range: NSRange, focusRange: NSRange) -> Bool {
        
        let mutableText = text.mutable
        
        switch type {
        case .bold, .italic, .keyboard, .strikethrough, .underscored:
            guard let attributedKey = type.discussionAttributedKeyWithoutValue else { return true }
            mutableText.addAttributes([attributedKey: true], range: range)
            let updatedText = updateStyles(text: mutableText)
            textView.textStorage.setAttributedString(updatedText)
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
    
    private func updateStyles(text: NSAttributedString) -> NSAttributedString {
        let newText = text.mutable
        text.enumerateAttributes(in: NSRange(location: 0, length: text.length)) { attrs, range, _ in
            var newFont = self.font
            
            if attrs[.discussionBold] != nil {
                newFont = newFont.bold
            }
            
            if attrs[.discussionItalic] != nil {
                newFont = newFont.italic
            }
            
            if attrs[.discussionKeyboard] != nil {
                newFont = codeFont
            }
            
            if attrs[.discussionStrikethrough] != nil {
                newText.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            
            if attrs[.discussionUnderscored] != nil {
                newText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            }
            
            newText.addAttribute(.font, value: newFont, range: range)
        }
        
        return newText
    }
}
