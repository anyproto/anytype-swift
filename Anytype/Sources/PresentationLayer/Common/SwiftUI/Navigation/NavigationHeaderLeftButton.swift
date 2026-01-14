import SwiftUI

struct NavigationHeaderLeftButton: View {

    let type: NavigationHeaderButtonType

    @Namespace private var glassNamespace

    var body: some View {
        switch type {
        case .back:
            PageNavigationBackButton()
                .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                .glassEffectInteractiveIOS26(in: Circle())
                .glassEffectIDIOS26("back", in: glassNamespace)
        case .dismiss:
            PageNavigationDismissButton()
                .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
                .glassEffectInteractiveIOS26(in: Circle())
                .glassEffectIDIOS26("dismiss", in: glassNamespace)
        case .none:
            EmptyView()
        }
    }
}
