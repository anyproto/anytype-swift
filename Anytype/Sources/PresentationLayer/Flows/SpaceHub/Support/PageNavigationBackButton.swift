import SwiftUI

struct PageNavigationBackButton: View {
    
    @Environment(\.pageNavigation) private var pageNavigation
    
    var body: some View {
        Image(asset: .X24.back)
            .onTapGesture {
                pageNavigation.pop()
            }
            .foregroundStyle(Color.Control.navPanelIcon)
    }
}
