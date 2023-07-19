import SwiftUI

struct PhraseTextView: UIViewRepresentable {
    @Binding var text: String
    let expandable: Bool
    let alignTextToCenter: Bool

    func makeUIView(context: Context) -> UIPhraseTextView {
        let textView = UIPhraseTextView()
        textView.textDidChange = context.coordinator.textDidChange(_:)
        textView.expandable = expandable
        return textView
    }
    
    func updateUIView(_ textView: UIPhraseTextView, context: UIViewRepresentableContext<PhraseTextView>) {
        textView.update(with: text, alignToCenter: alignTextToCenter)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text)
    }
}

extension PhraseTextView {
     
    @MainActor
    class Coordinator: NSObject {
        @Binding var text: String
        private let phraseTextValidator: PhraseTextValidatorProtocol = PhraseTextValidator()
     
        init(_ text: Binding<String>) {
            _text = text
        }
        
        @MainActor
        func textDidChange(_ text: String) {
            self.text = phraseTextValidator.validated(prevText: self.text, text: text)
        }
    }
    
}
