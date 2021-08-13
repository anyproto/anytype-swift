import SwiftUI

struct HomeSearchView: View {
    var body: some View {
        DragIndicator()
        AnytypeText("Search here", style: .title)
        Spacer()
    }
}

struct HomeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        HomeSearchView()
    }
}
