import SwiftUI

struct AnytypeText: View {
    let text: LocalizedStringKey
    let font: Font
    
    init(_ text: String, style: AnytypeFontBuilder.TextStyle) {
        self.text = LocalizedStringKey(text)
        self.font = AnytypeFontBuilder.font(textStyle: style)
    }
    
    init(
        _ text: String,
        name: AnytypeFontBuilder.FontName,
        size: CGFloat,
        weight: Font.Weight
    ) {
        self.text = LocalizedStringKey(text)
        self.font = AnytypeFontBuilder.font(name: name, size: size, weight: weight)
    }
    
    var body: some View {
        Text(text).font(font)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        AnytypeText("Foo", style: .body)
    }
}
