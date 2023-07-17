import SwiftUI

struct DotsView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            DotView()
            Spacer()
            DotView(delay: 0.3)
            Spacer()
            DotView(delay: 0.6)
        }
        .frame(idealWidth: 50, idealHeight: 6)
    }
}

struct DotsView_Previews: PreviewProvider {
    static var previews: some View {
        DotsView()
    }
}
