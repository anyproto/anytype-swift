import SwiftUI
import AnytypeCore

struct AnytypeText: View {
    private let textView: AnyView
    
    init(_ text: String, style: AnytypeFont, color: Color) {
        let spacing = style.lineSpacing
        
        textView = Self.buildText(text, style: style)
            .foregroundColor(color)
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
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
        
        return Text(text).font(font)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title, color: .textPrimary)
            AnytypeText("Foo", style: .body, color: .textPrimary)
            AnytypeText("Foo", style: .relation3Regular, color: .textPrimary)
            AnytypeText("collapse", style: .codeBlock, color: .textPrimary)
        }
    }
}
