#if DEBUG
import SwiftUI

struct TypographyExample: View {
    var body: some View {
        ScrollView() {
            ForEach(AnyTypeFont.TextStyle.allCases, id: \.self) { style in
                VStack {
                    Text("\(String(describing: style))").anyTypeFont(style)
                    Text("The quick brown fox jumps over the lazy dog").anyTypeFont(style)
                }.padding(10)
            }
        }
    }
}

struct TypographyExample_Previews: PreviewProvider {
    static var previews: some View {
        TypographyExample()
    }
}
#endif
