import SwiftUI

struct AutofocusedTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    @Binding var text: String
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextField(placeholder: placeholder, placeholderFont: placeholderFont, text: $text)
        } else {
            AnytypeTextField(placeholder: placeholder, placeholderFont: placeholderFont, text: $text)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, placeholderFont: placeholderFont, text: $text)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if text.isEmpty {
                        isFocused = true
                    }
                }
            }
    }
}
