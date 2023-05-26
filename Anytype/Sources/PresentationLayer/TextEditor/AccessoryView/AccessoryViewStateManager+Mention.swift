import Foundation

extension AccessoryViewStateManagerImpl: MentionViewDelegate {
    func selectMention(_ mention: MentionObject) {
        guard let textView = switcher.data?.textView, let info = switcher.data?.info else { return }
        guard let mentionSymbolPosition = triggerSymbolPosition,
              let newMentionPosition = textView.position(from: mentionSymbolPosition, offset: -1) else { return }
        guard let caretPosition = textView.caretPosition else { return }
        guard let oldText = textView.attributedText else { return }
        
        let mentionString = NSMutableAttributedString(string: mention.name)
        mentionString.addAttribute(.mention, value: mention.id, range: NSMakeRange(0, mentionString.length))
        
        let newMentionOffset = textView.offsetFromBegining(newMentionPosition)
        let mentionSearchTextLength = textView.offset(from: newMentionPosition, to: caretPosition)
        let mentionSearchTextRange = NSMakeRange(newMentionOffset, mentionSearchTextLength)
        
        let newText = NSMutableAttributedString(attributedString: oldText)
        newText.replaceCharacters(in: mentionSearchTextRange, with: mentionString)
       
        let lastMentionCharacterPosition = newMentionOffset + mentionString.length
        newText.insert(NSAttributedString(string: " "), at: lastMentionCharacterPosition)
        let newCaretPosition = NSMakeRange(lastMentionCharacterPosition + 2, 0) // 2 = space + 1 more char

        textView.attributedText = newText
        textView.selectedRange = newCaretPosition
        handler.changeTextForced(newText, blockId: info.id)

        AnytypeAnalytics.instance().logChangeTextStyle(.mention(MentionData.noDetails(blockId: "")))
    }
}
