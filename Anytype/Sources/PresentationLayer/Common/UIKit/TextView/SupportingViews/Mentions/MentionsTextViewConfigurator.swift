import UIKit

final class MentionsTextViewConfigurator  {
    
    private enum Constants {
        static let buttonOffset = CGPoint(x: 4, y: 4)
    }
    
    private let didSelectMention: (String) -> Void
    
    init(didSelectMention: @escaping (String) -> Void) {
        self.didSelectMention = didSelectMention
    }
    
    func configure(textView: UITextView) {
        CATransaction.setCompletionBlock { [weak self] in
            DispatchQueue.main.async {
                textView.subviews.filter { $0 is MentionButton }.forEach { $0.removeFromSuperview() }
                guard let text = textView.attributedText,
                      text.length > 0 else { return }
                text.enumerateAttribute(.attachment,
                                        in: NSRange(location: 0, length: text.length)) { value, _, _ in
                    guard let attachment = value as? MentionAttachment,
                          let mentionRect = textView.layoutManager.mentionRect(for: attachment),
                          let attachmentRect = textView.layoutManager.rect(for: attachment) else { return }
                    self?.addMentionInteractionButtons(
                        to: textView,
                        frames: [mentionRect, attachmentRect],
                        pageId: attachment.pageId
                    )
                }
            }
        }
    }
    
    private func addMentionInteractionButtons(to textView: UITextView, frames: [CGRect], pageId: String) {
        frames.forEach {
            let button = MentionButton(frame: $0.offsetBy(dx: Constants.buttonOffset.x,
                                                          dy: Constants.buttonOffset.y))
            button.isExclusiveTouch = true
            button.addAction(UIAction(handler: { [weak self] _ in
                self?.didSelectMention(pageId)
            }), for: .touchUpInside)
            textView.addSubview(button)
        }
    }
}
