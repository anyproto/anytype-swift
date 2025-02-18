import SwiftUI

struct RoundedTextFieldWithTitle: View {
    
    let title: String
    @Binding var text: String
    
    init(title: String, text: Binding<String>) {
        self.title = title
        _text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .calloutRegular).foregroundColor(.Text.secondary)
            AnytypeTextField(placeholder: Loc.Object.Title.placeholder, font: .bodySemibold, text: $text)
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
        text: .constant("My name")
    )
}
