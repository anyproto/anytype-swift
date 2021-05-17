import SwiftUI

struct AnytypeText: View {
    let textView: Text
    
    init(_ text: String, style: AnytypeFontBuilder.TextStyle) {
        let text = LocalizedStringKey(text)
        let font = AnytypeFontBuilder.font(textStyle: style)
        
        textView = Text(text).font(font)
    }
    
    init(
        _ text: String,
        name: AnytypeFontBuilder.FontName,
        size: CGFloat,
        weight: Font.Weight
    ) {
        let text = LocalizedStringKey(text)
        let font = AnytypeFontBuilder.font(name: name, size: size, weight: weight)
        
        textView = Text(text).font(font)
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
