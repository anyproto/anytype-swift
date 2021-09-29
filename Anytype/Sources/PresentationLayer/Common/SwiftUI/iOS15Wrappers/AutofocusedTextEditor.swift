import SwiftUI

struct AutofocusedTextEditor: View {
    @Binding var text: String
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextEditor(text: $text)
        } else {
            TextEditor(text: $text)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextEditor: View {
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $text)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
    }
}
