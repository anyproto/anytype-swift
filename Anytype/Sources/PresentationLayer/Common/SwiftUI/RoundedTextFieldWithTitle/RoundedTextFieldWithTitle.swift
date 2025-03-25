import SwiftUI

struct RoundedTextFieldWithTitle: View {
    
    let title: String
    let placeholder: String
    @Binding var text: String
    
    init(title: String, placeholder: String, text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        _text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .calloutRegular).foregroundColor(.Text.secondary)
            AnytypeTextField(placeholder: placeholder, font: .bodySemibold, text: $text)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(12, color: .Shape.primary, lineWidth: 0.5)
    }
}

#Preview {
    RoundedTextFieldWithTitle(
        title: "Name",
        placeholder: "Untitled",
        text: .constant("My name")
    )
}
