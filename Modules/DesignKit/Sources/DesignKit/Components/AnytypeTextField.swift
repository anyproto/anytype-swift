import SwiftUI

public struct AnytypeTextField: View {
    
    let placeholder: String
    let font: AnytypeFont
    let axis: Axis
    @Binding var text: String
    
    public init(placeholder: String, font: AnytypeFont, axis: Axis = .horizontal, text: Binding<String>) {
        self.placeholder = placeholder
        self.font = font
        self.axis = axis
        self._text = text
    }
    
    public var body: some View {
        Group {
            TextField("", text: $text, axis: axis)
                .placeholder(when: text.isEmpty) {
                    AnytypeText(placeholder, style: font)
                        .foregroundColor(.Text.tertiary)
                }
                .font(AnytypeFontBuilder.font(anytypeFont: font))
                .kerning(font.config.kern)
                .accessibilityLabel("TextField")
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
