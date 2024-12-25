import SwiftUI

struct PageNavigationBackButton: View {
    
    @Environment(\.pageNavigation) private var pageNavigation
    
    var body: some View {
        Image(asset: .X24.back)
            .foregroundStyle(Color.Control.navPanelIcon)
            .onTapGesture {
                if #available(iOS 17.0, *) {
                    ReturnToWidgetsTip.numberOfBackTaps += 1
                }
                pageNavigation.pop()
            }
            .foregroundColor(.Control.navPanelIcon)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        if #available(iOS 17.0, *) {
                            ReturnToWidgetsTip.usedLongpress = true
                        }
                        pageNavigation.popToFirstInSpace()
                    }
            )
    }
}
