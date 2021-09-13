import UIKit

extension TextBlockContentView: AccessoryViewSwitcherDelegate {
    func mentionSelected(_ mention: MentionObject, from: UITextPosition, to: UITextPosition) {
        // TODO: Accessory check if no need
        textView.textView.insert(
            mention,
            from: from,
            to: to,
            font: currentConfiguration.text.anytypeFont
        )

        self.currentConfiguration.actionHandler.handleAction(
            .textView(
                action: .changeText(self.textView.textView.attributedText),
                block: self.currentConfiguration.block
            ),
            blockId: self.currentConfiguration.information.id
        )
    }
    
    func didEnterURL(_ url: URL?) {
        let range = textView.textView.selectedRange
        currentConfiguration.actionHandler.handleAction(
            .setLink(currentConfiguration.text.attrString, url, range),
            blockId: currentConfiguration.information.id
        )
    }
}
