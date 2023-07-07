import SwiftUI

struct PhraseTextView: UIViewRepresentable {
    @Binding var text: String
    let expandable: Bool
    let alignTextToCenter: Bool

    func makeUIView(context: Context) -> UIPhraseTextView {
        let textView = UIPhraseTextView()
        textView.textDidChange = { text in
            self.text = text
        }
        textView.expandable = expandable
        return textView
    }
    
    func updateUIView(_ textView: UIPhraseTextView, context: UIViewRepresentableContext<PhraseTextView>) {
        textView.update(with: text, alignToCenter: alignTextToCenter)
    }
}
