import SwiftUI

struct AutofocusedTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    let shouldSkipFocusOnFilled: Bool

    @Binding var text: String

    init(
        placeholder: String,
        placeholderFont: AnytypeFont,
        shouldSkipFocusOnFilled: Bool = false,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.placeholderFont = placeholderFont
        self.shouldSkipFocusOnFilled = shouldSkipFocusOnFilled
        self._text = text
    }
    
    var body: some View {
        NewAutofocusedTextField(
            placeholder: placeholder,
            placeholderFont: placeholderFont,
            shouldSkipFocusOnFilled: shouldSkipFocusOnFilled,
            text: $text
        )
    }
}


private struct NewAutofocusedTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    let shouldSkipFocusOnFilled: Bool
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, placeholderFont: placeholderFont, text: $text)
            .focused($isFocused)
            .task {
                isFocused = text.isEmpty || !shouldSkipFocusOnFilled
            }
    }
}
