import SwiftUI

struct AnytypeTextField: View {
    let placeholder: String
    let placeholderFont: AnytypeFont
    @Binding var text: String

    var body: some View {
        Group {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    AnytypeText(placeholder, style: placeholderFont, color: .textTertiary)
                }
        }
    }
}

struct AnytypeTextField_Previews: PreviewProvider {
    @State static var text: String = "text"
    static var previews: some View {
        AnytypeTextField(placeholder: "place", placeholderFont: .uxBodyRegular, text: $text)
            .background(Color.yellow)
    }
}
