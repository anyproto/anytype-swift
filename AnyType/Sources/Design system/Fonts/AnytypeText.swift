import SwiftUI

struct AnytypeText: View {
    private let textView: AnyView
    
    init(_ text: String, style: AnytypeFontBuilder.TextStyle) {
        let font = AnytypeFontBuilder.font(textStyle: style)
        let spacing = AnytypeFontBuilder.customLineSpacing(textStyle: style)
        
        textView = Text(LocalizedStringKey(text)).font(font).modifier(OptionalLineSpacingModifier(spacing: spacing)).eraseToAnyView()
    }
    
    init(
        _ text: String,
        name: AnytypeFontBuilder.FontName,
        size: CGFloat,
        weight: Font.Weight
    ) {
        assert(name != .plex, "Custom plex font requires custom line spacing implementation")
        let font = AnytypeFontBuilder.font(name: name, size: size, weight: weight)
        
        textView = Text(LocalizedStringKey(text)).font(font).eraseToAnyView()
    }
    
    var body: some View {
        textView
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnytypeText("Foo", style: .title)
            AnytypeText("Foo", style: .body)
            AnytypeText("Foo", style: .footnote)
            AnytypeText("collapse", style: .codeBlock)
        }
    }
}
