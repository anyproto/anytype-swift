import SwiftUI
import AnytypeCore

struct AnytypeText: View {
    
    private let textView: Text
    private let spacing: CGFloat

    private init(textView: Text, spacing: CGFloat) {
        self.textView = textView
        self.spacing = spacing
    }

    init(_ text: String, style: AnytypeFont, color: Color) {
        let spacing = style.lineSpacing
        
        self.textView = Self.buildText(text, style: style)
                 .foregroundColor(color)
        self.spacing = spacing
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
        
        textView = Text(text).font(font)
        self.spacing = 0
    }
    
    var body: some View {
        textView
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
            // TODO: Fix
            // For two AnytypeText in VStack in List, multiline working incorrectly when padding is small (example: 1.8).
            // See featureToggle list in debug menu. Replace Text to AnytypeText.
            .padding(.vertical, spacing / 2)
    }
    
    private static func buildText(_ text: String, style: AnytypeFont) -> Text {
        let font = AnytypeFontBuilder.font(anytypeFont: style)
        
        return Text(.init(text)).font(font).kerning(style.kern)
    }
    
    public static func + (lhs: AnytypeText, rhs: AnytypeText) -> AnytypeText {
        let textView = lhs.textView + rhs.textView
        let spacing = max(lhs.spacing, rhs.spacing)
        return AnytypeText(textView: textView, spacing: spacing)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title, color: .Text.primary)
            AnytypeText("Foo", style: .bodyRegular, color: .Text.primary)
            AnytypeText("Foo", style: .relation3Regular, color: .Text.primary)
            AnytypeText("collapse", style: .codeBlock, color: .Text.primary)
        }
    }
}
