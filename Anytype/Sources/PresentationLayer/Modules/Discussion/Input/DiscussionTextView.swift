import Foundation
import SwiftUI

struct DiscussionTextView: UIViewRepresentable {
    
    @Binding var editing: Bool
    
    func makeCoordinator() -> DiscussionTextViewCoordinator {
        DiscussionTextViewCoordinator(editing: $editing)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        // Text style
        let style = AnytypeFont.bodyRegular
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = style.lineHeightMultiple
        textView.typingAttributes = [
            .font: UIKitFontBuilder.uiKitFont(font: style),
            .paragraphStyle: paragraph
        ]
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if editing {
            if !textView.isFirstResponder {
                Task { @MainActor in // Async for fix "AttributeGraph: cycle detected through attribute"
                    textView.becomeFirstResponder()
                }
            }
        } else {
            if textView.isFirstResponder {
                Task { @MainActor in // Async for fix "AttributeGraph: cycle detected through attribute"
                    textView.resignFirstResponder()
                }
            }
        }
    }
}

#Preview {
    DiscussionTextView(editing: .constant(false))
}
