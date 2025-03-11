import SwiftUI

struct AnytypeTextField: View {
    let placeholder: String
    let font: AnytypeFont
    let axis: Axis
    @Binding var text: String
    
    init(placeholder: String, font: AnytypeFont, axis: Axis = .horizontal, text: Binding<String>) {
        self.placeholder = placeholder
        self.font = font
        self.axis = axis
        _text = text
    }

    var body: some View {
        Group {
            TextField("", text: $text, axis: axis)
                .placeholder(when: text.isEmpty) {
                    AnytypeText(placeholder, style: font)
                        .foregroundColor(.Text.tertiary)
                }
                .font(AnytypeFontBuilder.font(anytypeFont: font))
                .kerning(font.config.kern)
        }
    }
}

struct AnytypeTextField_Previews: PreviewProvider {
    @State static var text: String = "text"
    static var previews: some View {
        AnytypeTextField(placeholder: "place", font: .uxBodyRegular, text: $text)
            .background(Color.yellow)
    }
}
