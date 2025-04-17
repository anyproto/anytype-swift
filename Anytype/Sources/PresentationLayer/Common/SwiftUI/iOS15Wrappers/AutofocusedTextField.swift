import SwiftUI

struct AutofocusedTextField: View {
    let placeholder: String
    let font: AnytypeFont
    let shouldSkipFocusOnFilled: Bool
    let axis: Axis

    @Binding var text: String

    init(
        placeholder: String,
        font: AnytypeFont,
        shouldSkipFocusOnFilled: Bool = false,
        axis: Axis = .horizontal,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.font = font
        self.shouldSkipFocusOnFilled = shouldSkipFocusOnFilled
        self.axis = axis
        self._text = text
    }
    
    var body: some View {
        NewAutofocusedTextField(
            placeholder: placeholder,
            font: font,
            shouldSkipFocusOnFilled: shouldSkipFocusOnFilled,
            axis: axis,
            text: $text
        )
    }
}


private struct NewAutofocusedTextField: View {
    let placeholder: String
    let font: AnytypeFont
    let shouldSkipFocusOnFilled: Bool
    var axis: Axis = .horizontal
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        AnytypeTextField(placeholder: placeholder, font: font, axis: axis, text: $text)
            .focused($isFocused)
            .task {
                isFocused = text.isEmpty || !shouldSkipFocusOnFilled
            }
    }
}
