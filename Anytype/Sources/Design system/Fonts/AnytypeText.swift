import SwiftUI
import AnytypeCore

struct AnytypeText: View {
    private let textView: AnyView
    
    init(_ text: String, style: AnytypeFontBuilder.TextStyle, color: Color) {
        let spacing = AnytypeFontBuilder.lineSpacing(style)
        
        textView = Self.buildText(text, style: style)
            .foregroundColor(color)
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
            .padding(.vertical, spacing / 2)
            .eraseToAnyView()
    }
    
    init(
        _ text: String,
        name: FontName,
        size: CGFloat,
        weight: Font.Weight
    ) {
        anytypeAssert(name != .plex, "Custom plex font requires custom line spacing implementation")
        let font = AnytypeFontBuilder.font(name: name, size: size, weight: weight)
        
        textView = Text(LocalizedStringKey(text)).font(font).eraseToAnyView()
    }
    
    var body: some View {
        textView
    }
    
    static func buildText(_ text: String, style: AnytypeFontBuilder.TextStyle) -> Text {
        let font = AnytypeFontBuilder.font(textStyle: style)
        
        return Text(LocalizedStringKey(text)).font(font)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title, color: .textPrimary)
            AnytypeText("Foo", style: .bodyRegular, color: .textPrimary)
            AnytypeText("Foo", style: .relation3Regular, color: .textPrimary)
            AnytypeText("collapse", style: .codeBlock, color: .textPrimary)
        }
    }
}
