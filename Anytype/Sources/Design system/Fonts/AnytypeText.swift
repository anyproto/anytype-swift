import SwiftUI
import AnytypeCore

struct AnytypeText: View {
    private let textView: AnyView
    
    init(_ text: String, style: AnytypeFont, color: Color) {
        let spacing = style.lineSpacing
        
        textView = Self.buildText(text, style: style)
            .foregroundColor(color)
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
        // TODO: Fix
        // For two AnytypeText in VStack in List, multiline working incorrectly when padding is small (example: 1.8).
        // See featureToggle list in debug menu. Replace Text to AnytypeText.
            .padding(.vertical, spacing / 2)
            .eraseToAnyView()
    }
    
    init(
        _ text: String,
        name: AnytypeFont.FontName,
        size: CGFloat,
        weight: Font.Weight
    ) {
        anytypeAssert(
            name != .plex,
            "Custom plex font requires custom line spacing implementation",
            domain: .anytypeText
        )
        let font = AnytypeFontBuilder.font(name: name, size: size, weight: weight)
        
        textView = Text(text).font(font).eraseToAnyView()
    }
    
    var body: some View {
        textView
    }
    
    private static func buildText(_ text: String, style: AnytypeFont) -> Text {
        let font = AnytypeFontBuilder.font(anytypeFont: style)
        
        return Text(text).font(font).kerning(style.kern)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title, color: .TextNew.primary)
            AnytypeText("Foo", style: .body, color: .TextNew.primary)
            AnytypeText("Foo", style: .relation3Regular, color: .TextNew.primary)
            AnytypeText("collapse", style: .codeBlock, color: .TextNew.primary)
        }
    }
}
