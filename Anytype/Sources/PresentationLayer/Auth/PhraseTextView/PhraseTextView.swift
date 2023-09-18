import SwiftUI

@MainActor
struct PhraseTextView: UIViewRepresentable {
    @Binding var text: String
    let noninteractive: Bool
    let alignTextToCenter: Bool
    let hideWords: Bool

    func makeUIView(context: Context) -> UIPhraseTextView {
        let textView = UIPhraseTextView()
        textView.textDidChange = context.coordinator.textDidChange(_:)
        textView.noninteractive = noninteractive
        return textView
    }
    
    func updateUIView(_ textView: UIPhraseTextView, context: UIViewRepresentableContext<PhraseTextView>) {
        textView.update(with: text, alignToCenter: alignTextToCenter, hidden: hideWords)
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
