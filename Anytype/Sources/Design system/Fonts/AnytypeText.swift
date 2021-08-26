import SwiftUI
import AnytypeCore

struct AnytypeText: View {
    private let textView: AnyView
    
    init(_ text: String, style: AnytypeFont) {
        let spacing = style.lineSpacing
        
        textView = Self.buildText(text, style: style)
            .modifier(OptionalLineSpacingModifier(spacing: spacing))
            .eraseToAnyView()
    }
    
    init(
        _ text: String,
        name: AnytypeFont.FontName,
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
    
    static func buildText(_ text: String, style: AnytypeFont) -> Text {
        let font = AnytypeFontBuilder.font(anytypeFont: style)
        
        return Text(LocalizedStringKey(text)).font(font)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title)
            AnytypeText("Foo", style: .bodyRegular)
            AnytypeText("Foo", style: .relation3Regular)
            AnytypeText("collapse", style: .codeBlock)
        }
    }
}
