import SwiftUI

struct AutofocusedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextField(placeholder: placeholder, text: $text)
        } else {
            AnytypeTextField(placeholder: placeholder, text: $text)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, text: $text)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
    }
}
