import SwiftUI

struct DotsView: View {
    var body: some View {
        GeometryReader { reader in
            // Fix Circle size.
            // With strokeBorder API, clrcle calculate incorrect size for width.
            // Width and height should be equal, but width is bigger.
            // At the same time normal behavior for stroke API 😬.
            let side = min(reader.size.width, reader.size.height)
            HStack(alignment: .center, spacing: 0) {
                DotView()
                    .frame(width: side, height: side)
                Spacer()
                DotView(delay: 0.3)
                    .frame(width: side, height: side)
                Spacer()
                DotView(delay: 0.6)
                    .frame(width: side, height: side)
            }
        }
        .frame(idealWidth: 50, idealHeight: 6)
    }
}

struct DotsView_Previews: PreviewProvider {
    static var previews: some View {
        DotsView()
    }
}
