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
            titleView
        } rightContent: {
            settingsButton
        }
        .task { await model.startSubscriptions() }
    }

    private var titleView: some View {
        HStack(spacing: 12) {
            IconView(icon: model.spaceIcon)
                .frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.spaceName, style: .uxTitle2Semibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                if model.sharedSpace, !model.isOneToOne {
                    AnytypeText(model.spaceMembers, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                } else {
                    AnytypeText(model.spaceUxType, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                }
            }
            Spacer()
        }
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
