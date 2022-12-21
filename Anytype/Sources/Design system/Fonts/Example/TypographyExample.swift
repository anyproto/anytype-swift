import SwiftUI

struct TypographyExample: View {
    var body: some View {
        ScrollView() {
            ForEach(AnytypeFont.allCases, id: \.self) { style in
                VStack {
                    AnytypeText("\(String(describing: style))", style: style, color: .TextNew.primary)
                    AnytypeText("The quick brown fox jumps over the lazy dog", style: style, color: .TextNew.primary)
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
