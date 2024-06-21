import SwiftUI

struct AutofocusedTextField: View {
    let placeholder: String
    let font: AnytypeFont
    let shouldSkipFocusOnFilled: Bool

    @Binding var text: String

    init(
        placeholder: String,
        font: AnytypeFont,
        shouldSkipFocusOnFilled: Bool = false,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.font = font
        self.shouldSkipFocusOnFilled = shouldSkipFocusOnFilled
        self._text = text
    }
    
    var body: some View {
        NewAutofocusedTextField(
            placeholder: placeholder,
            font: font,
            shouldSkipFocusOnFilled: shouldSkipFocusOnFilled,
            text: $text
        )
    }
}


private struct NewAutofocusedTextField: View {
    let placeholder: String
    let font: AnytypeFont
    let shouldSkipFocusOnFilled: Bool
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, font: font, text: $text)
            .focused($isFocused)
            .task {
                isFocused = text.isEmpty || !shouldSkipFocusOnFilled
            }
    }
}
