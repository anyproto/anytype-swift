import Foundation
import SwiftUI

struct WidgetsHeaderView: View {
    @State private var model: WidgetsHeaderViewModel
    let navigationButtonType: NavigationHeaderButtonType

    @Namespace private var glassNamespace

    init(spaceId: String, navigationButtonType: NavigationHeaderButtonType, onSpaceSelected: @escaping () -> Void) {
        _model = State(initialValue: WidgetsHeaderViewModel(spaceId: spaceId, onSpaceSelected: onSpaceSelected))
        self.navigationButtonType = navigationButtonType
    }

    var body: some View {
        NavigationHeader(
            navigationButtonType: navigationButtonType,
            isTitleInteractive: false
        ) {
            EmptyView()
        } rightContent: {
            settingsButton
        }
        .task { await model.startSubscriptions() }
    }

    @ViewBuilder
    private var settingsButton: some View {
        if model.canEdit {
            Button {
                model.onTapSpaceSettings()
            } label: {
                Image(asset: .X24.spaceSettings)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: NavigationHeaderConstants.buttonSize, height: NavigationHeaderConstants.buttonSize)
            }
            .glassEffectInteractiveIOS26(in: Circle())
            .glassEffectIDIOS26("settings", in: glassNamespace)
        }
    }
}
