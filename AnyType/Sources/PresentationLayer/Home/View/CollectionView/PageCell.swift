import SwiftUI

struct PageCell: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("🤠").font(.robotMonoRegular(48))
                Text("Shiso Burger").font(.inter(13))
                Text("Human").font(.inter(12)).foregroundColor(.gray)
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
