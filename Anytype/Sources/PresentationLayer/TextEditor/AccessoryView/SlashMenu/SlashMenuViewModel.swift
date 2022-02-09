import BlocksModels
import Combine
import ProtobufMessages
import UIKit

final class SlashMenuViewModel {
    var info: BlockInformation? {
        didSet {
            
        }
    }
    
    private var initialCaretPosition: UITextPosition?
    private weak var textView: UITextView?
    
    private let handler: SlashMenuActionHandler
    
    init(handler: SlashMenuActionHandler) {
        self.handler = handler
    }
    
    func handle(_ action: SlashAction) {
        guard let info = info else { return }

        handler.handle(action, blockId: info.id)
        removeSlashMenuText()
    }
    
    func didShowMenuView(from textView: UITextView) {
        self.textView = textView
        guard let caretPosition = textView.caretPosition else { return }
        // -1 because in text "Hello, everyone/" we want to store position before slash, not after
        initialCaretPosition = textView.position(from: caretPosition, offset: -1)
    }
    
    private func removeSlashMenuText() {
        // After we select any action from actions menu we must delete /symbol
        // and all text which was typed after /
        //
        // We create text range from two text positions and replace text in
        // this range with empty string
        guard let initialCaretPosition = initialCaretPosition,
              let textView = textView,
              let currentPosition = textView.caretPosition,
              let textRange = textView.textRange(from: initialCaretPosition, to: currentPosition),
              let info = info else {
            return
        }
        textView.replace(textRange, withText: "")
        
        guard let text = textView.attributedText else { return }
        handler.changeText(text, info: info)
    }
}
