import SwiftUI

struct DotsView: View {
    var body: some View {
        HStack(spacing: 15) {
            DotView()
            DotView(delay: 0.3)
            DotView(delay: 0.6)
        }
    }
}

struct DotsView_Previews: PreviewProvider {
    static var previews: some View {
        DotsView()
    }
}
