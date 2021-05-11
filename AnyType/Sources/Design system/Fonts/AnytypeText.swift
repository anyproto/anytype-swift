import SwiftUI

struct AnytypeText: View {
    let text: LocalizedStringKey
    let style: AnytypeFont.TextStyle
    
    init(_ text: LocalizedStringKey, style: AnytypeFont.TextStyle) {
        self.text = text
        self.style = style
    }
    
    var body: some View {
        Text(text).anyTypeFont(style)
    }
}

struct AnytypeText_Previews: PreviewProvider {
    static var previews: some View {
        AnytypeText("Foo", style: .body)
    }
}
