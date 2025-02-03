import Foundation
import SwiftUI

struct ChatTextView: UIViewRepresentable {
    
    private enum Constants {
        static let anytypeFont = AnytypeFont.bodyRegular
        static let font = UIKitFontBuilder.uiKitFont(font: Constants.anytypeFont)
        static let anytypeCodeFont = AnytypeFont.codeBlock
        static let codeFont = UIKitFontBuilder.uiKitFont(font: anytypeCodeFont)
    }
    
    @Binding var text: NSAttributedString
    @Binding var editing: Bool
    @Binding var mention: ChatTextMention
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let linkTo: (_ range: NSRange) -> Void
    
    @State private var height: CGFloat = 0
    
    func makeCoordinator() -> ChatTextViewCoordinator {
        ChatTextViewCoordinator(
            text: $text,
            editing: $editing,
            mention: $mention,
            height: $height,
            maxHeight: maxHeight,
            anytypeFont: Constants.anytypeFont,
            anytypeCodeFont: Constants.anytypeCodeFont
        )
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = AnytypeUITextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        textView.anytypeDelegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 0, bottom: 10, right: 10)
        textView.textContainer.lineFragmentPadding = 0
        textView.notEditableAttributes = [.chatMention]
        textView.backgroundColor = .clear
        
        if let textContentManager = textView.textLayoutManager?.textContentManager {
            textContentManager.delegate = context.coordinator
        }
        
        // Text style
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = Constants.anytypeFont.lineHeightMultiple
        textView.typingAttributes = [
            .font: Constants.font,
            .paragraphStyle: paragraph,
            .kern: Constants.anytypeFont.config.kern
        ]
        context.coordinator.defaultTypingAttributes = textView.typingAttributes
        textView.textColor = .Text.primary
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.linkTo = linkTo
        
        Task { @MainActor in
            // Async for fix "AttributeGraph: cycle detected through attribute"
            context.coordinator.changeEditingStateIfNeeded(textView: textView, editing: editing)
            context.coordinator.updateTextIfNeeded(textView: textView, string: text)
        }
    }
   
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        return CGSize(width: proposal.width ?? 0, height: max(minHeight, height))
    }
}

#Preview {
    ChatTextView(
        text: .constant(NSAttributedString()),
        editing: .constant(false),
        mention: .constant(.finish),
        minHeight: 54,
        maxHeight: 212,
        linkTo: { _ in }
    )
}
