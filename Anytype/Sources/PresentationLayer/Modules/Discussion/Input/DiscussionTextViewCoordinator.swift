import Foundation
import UIKit
import SwiftUI
import Services

final class DiscussionTextViewCoordinator: NSObject, UITextViewDelegate, NSTextContentStorageDelegate {
    
    @Binding private var editing: Bool
    @Binding private var height: CGFloat
    
    private let maxHeight: CGFloat
    private let markdownListener: MarkdownListener
    
    init(editing: Binding<Bool>, height: Binding<CGFloat>, maxHeight: CGFloat) {
        self._editing = editing
        self._height = height
        self.maxHeight = maxHeight
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
            return true
        case .addStyle(let markupType, let text, let range, let focusRange):
            return addStyle(textView: textView, type: markupType, text: text, range: range, focusRange: focusRange)
        }
    }
    
    // MARK: - NSTextContentStorageDelegate
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        
        var font = UIKitFontBuilder.uiKitFont(font: .bodyRegular)
        
        if originalText.attribute(.discussionBold, at: 0, effectiveRange: nil) != nil{
            font = font.bold
        }
        
        return nil
    }
    
    
    // MARK: - Private
    
    func addStyle(textView: UITextView, type: MarkupType, text: NSAttributedString, range: NSRange, focusRange: NSRange) -> Bool {
        switch type {
        case .bold:
            textView.textStorage.setAttributedString(text)
            textView.textStorage.setAttributes([.font: UIKitFontBuilder.uiKitFont(font: .bodyRegular).bold], range: range)
            textView.selectedRange = focusRange
            return false
        case .italic:
            print("apply italic")
        case .keyboard:
            print("apply keyboard")
        case .strikethrough:
            print("apply strikethrough")
        case .underscored:
            print("apply underline")
        case .textColor:
            print("apply textColor")
        case .backgroundColor(let middlewareColor):
            print("apply backgroundColor")
        case .link(let uRL):
            print("apply link")
        case .linkToObject(let string):
            print("apply linkToObject")
        case .mention(let mentionObject):
            print("apply mention")
        case .emoji(let emoji):
            print("apply emoji")
        }
        return true
    }
}
