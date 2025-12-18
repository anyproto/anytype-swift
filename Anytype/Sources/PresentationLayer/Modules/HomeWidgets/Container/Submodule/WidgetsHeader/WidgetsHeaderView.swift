import Foundation
import SwiftUI

struct WidgetsHeaderView: View {

    @StateObject private var model: WidgetsHeaderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.pageNavigation) private var pageNavigation

    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        _model = StateObject(wrappedValue: WidgetsHeaderViewModel(spaceId: spaceId, onSpaceSelected: onSpaceSelected))
    }

    var body: some View {
        NavigationHeaderContainer(spacing: 20) {
            ExpandedTapAreaButton {
                dismiss()
                pageNavigation.popToFirstInSpace()
            } label: {
                Image(asset: .X32.Island.vault)
                    .navPanelDynamicForegroundStyle()
            }
        } titleView: {
            HStack(spacing: 12) {
                IconView(icon: model.spaceIcon)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(model.spaceName, style: .uxTitle2Semibold)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    if model.sharedSpace, !model.isOneToOne {
                        AnytypeText(model.spaceMembers, style: .relation2Regular)
                            .foregroundColor(.Control.transparentSecondary)
                    } else {
                        AnytypeText(model.spaceUxType, style: .relation2Regular)
                            .foregroundColor(.Control.transparentSecondary)
                    }
                }
                Spacer()
            }
        } rightView: {
            if model.canEdit {
                Image(asset: .X24.spaceSettings)
                    .foregroundStyle(Color.Control.transparentSecondary)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: PageNavigationHeaderConstants.height)
        .background {
            HomeBlurEffectView(direction: .topToBottom)
                .ignoresSafeArea()
        }
        .fixTappableArea()
        .onTapGesture {
            model.onTapSpaceSettings()
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
