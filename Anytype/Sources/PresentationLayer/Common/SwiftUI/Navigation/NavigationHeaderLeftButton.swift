import SwiftUI

struct NavigationHeaderLeftButton: View {

    let type: NavigationHeaderButtonType

    var body: some View {
        switch type {
        case .back:
            PageNavigationBackButton()
                .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                .glassEffectInteractiveIOS26(in: Circle())
        case .dismiss:
            PageNavigationDismissButton()
                .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                .glassEffectInteractiveIOS26(in: Circle())
        case .none:
            EmptyView()
        }
    }
}
