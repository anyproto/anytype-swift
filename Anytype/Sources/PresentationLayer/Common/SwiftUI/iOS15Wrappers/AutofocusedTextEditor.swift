import SwiftUI

struct AutofocusedTextEditor: View {
    @Binding var text: String
    
    let keyboardType: UIKeyboardType
    let shouldSkipFocusOnFilled: Bool
    
    init(text: Binding<String>, keyboardType: UIKeyboardType = .default, shouldSkipFocusOnFilled: Bool = false) {
        _text = text
        self.keyboardType = keyboardType
        self.shouldSkipFocusOnFilled = false
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextEditor(text: $text, keyboardType: keyboardType, shouldSkipFocusOnFilled: shouldSkipFocusOnFilled)
        } else {
            TextEditor(text: $text)
                .keyboardType(keyboardType)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextEditor: View {
    @Binding var text: String
    let shouldSkipFocusOnFilled: Bool

    @FocusState private var isFocused: Bool
    private let keyboardType: UIKeyboardType
    
    init(text: Binding<String>, keyboardType: UIKeyboardType = .default, shouldSkipFocusOnFilled: Bool) {
        _text = text
        self.keyboardType = keyboardType
        self.shouldSkipFocusOnFilled = shouldSkipFocusOnFilled

        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TextEditor(text: $text)
            .fixedSize(horizontal: false, vertical: true)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = text.isEmpty || !shouldSkipFocusOnFilled
                }
            }
            .keyboardType(keyboardType)
    }
}
