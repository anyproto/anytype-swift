import SwiftUI

struct AnytypeTextField: View {
    let placeholder: String
    let font: AnytypeFont
    var axis: Axis = .horizontal
    @Binding var text: String
    
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
