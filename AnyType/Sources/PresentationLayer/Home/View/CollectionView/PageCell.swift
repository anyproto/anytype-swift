import SwiftUI

struct PageCell: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("🤠").font(.system(size: UIFontMetrics.default.scaledValue(for: 48)))
                Text("Shiso Burger").anyTypeFont(.captionMedium)
                Text("Human").anyTypeFont(.footnote).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct PageCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            PageCell()
        }
        .previewLayout(.fixed(width: 300 , height: 400))
    }
}
