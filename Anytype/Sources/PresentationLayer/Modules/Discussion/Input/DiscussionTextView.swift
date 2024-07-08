import Foundation
import SwiftUI

struct DiscussionTextView: UIViewRepresentable {
    
    @Binding var editing: Bool
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    @State private var height: CGFloat = 0
    
    func makeCoordinator() -> DiscussionTextViewCoordinator {
        DiscussionTextViewCoordinator(editing: $editing, height: $height, maxHeight: maxHeight)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 0, bottom: 10, right: 0)
        
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
   
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        return CGSize(width: proposal.width ?? 0, height: max(minHeight, height))
    }
}

#Preview {
    DiscussionTextView(editing: .constant(false), minHeight: 54, maxHeight: 212)
}
