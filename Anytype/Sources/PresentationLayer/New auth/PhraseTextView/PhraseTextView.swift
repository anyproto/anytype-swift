import SwiftUI

struct PhraseTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UIPhraseTextView {
        let textView = UIPhraseTextView()
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textDidChange = { text in
            DispatchQueue.main.async {
                self.text = text
            }
        }
        return textView
    }
    
    func updateUIView(_ textView: UIPhraseTextView, context: UIViewRepresentableContext<PhraseTextView>) {
        textView.update(with: text)
    }
}
