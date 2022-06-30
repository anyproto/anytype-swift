import BlocksModels
import Combine
import ProtobufMessages
import UIKit

final class SlashMenuViewModel {
    var info: BlockInformation?
    
    private var selectedRange: NSRange?
    private weak var textView: UITextView?
    
    private let handler: SlashMenuActionHandler
    var resetSlashMenuHandler: (() -> Void)?
    
    init(handler: SlashMenuActionHandler) {
        self.handler = handler
    }
    
    func handle(_ action: SlashAction) {
        guard let info = info else { return }

        removeSlashMenuText()
        handler.handle(action, textView: textView, blockId: info.id, selectedRange: selectedRange ?? .zero)
        selectedRange = nil
        resetSlashMenuHandler?()
    }
    
    func didShowMenuView(from textView: UITextView) {
        self.textView = textView
        selectedRange = NSRange(
            location: textView.selectedRange.location - 1,
            length: 0
        )
    }
    
    private func removeSlashMenuText() {
        // After we select any action from actions menu we must delete /symbol
        // and all text which was typed after /
        //
        // We create text range from two text positions and replace text in
        // this range with empty string
        guard let selectedRange = selectedRange,
              let textView = textView,
              let info = info else {
            return
        }
        let mutableText = textView.attributedText.mutable

        let range = NSRange(
            location: selectedRange.location,
            length: textView.selectedRange.location - selectedRange.location
        )

        mutableText.replaceCharacters(in: range, with: "")
        handler.changeText(mutableText, info: info)
        textView.attributedText = mutableText
    }
}
