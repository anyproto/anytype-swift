import UIKit

final class MentionsTextViewConfigurator: CustomTextViewConfigurator  {
    
    private enum Constants {
        static let buttonOffset = CGPoint(x: 4, y: 4)
        static let mentionButtonTag = 5
    }
    
    private let didSelectMention: (String) -> Void
    
    init(didSelectMention: @escaping (String) -> Void) {
        self.didSelectMention = didSelectMention
    }
    
    func configure(textView: CustomTextView) {
        DispatchQueue.main.async {
            textView.textView.subviews.filter { $0 is MentionButton }.forEach { $0.removeFromSuperview() } 
            guard let text = textView.textView.attributedText,
                  text.length > 0 else { return }
            text.enumerateAttribute(.attachment,
                                    in: NSRange(location: 0, length: text.length)) { value, _, _ in
                guard let attachment = value as? MentionAttachment,
                      let mentionRect = attachment.mentionRect else { return }
                let button = MentionButton(frame: mentionRect.offsetBy(dx: Constants.buttonOffset.x
                                                                  , dy: Constants.buttonOffset.y))
                button.isExclusiveTouch = true
                button.accessibilityTraits = .button
                button.addAction(UIAction(handler: { [weak self] _ in
                    self?.didSelectMention(attachment.pageId)
                }), for: .touchUpInside)
                textView.textView.addSubview(button)
            }
        }
    }
}
