import SwiftUI

struct AutofocusedTextEditor: View {
    @Binding var text: String
    
    let keyboardType: UIKeyboardType
    
    init(text: Binding<String>, keyboardType: UIKeyboardType = .default) {
        _text = text
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextEditor(text: $text, keyboardType: keyboardType)
        } else {
            TextEditor(text: $text)
                .keyboardType(keyboardType)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextEditor: View {
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    private let keyboardType: UIKeyboardType
    
    init(text: Binding<String>, keyboardType: UIKeyboardType = .default) {
        _text = text
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        TextEditor(text: $text)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
            .keyboardType(keyboardType)
    }
}
