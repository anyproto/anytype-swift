import SwiftUI

struct AutofocusedTextField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        if #available(iOS 15.0, *) {
            NewAutofocusedTextField(title: title, text: $text)
        } else {
            TextField(title, text: $text)
        }
    }
}

@available(iOS 15.0, *)
private struct NewAutofocusedTextField: View {
    let title: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(title, text: $text)
            .focused($isFocused)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
    }
}
