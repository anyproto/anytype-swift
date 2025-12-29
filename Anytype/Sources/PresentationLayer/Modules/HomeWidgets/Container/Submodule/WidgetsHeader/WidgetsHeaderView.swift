import Foundation
import SwiftUI

struct WidgetsHeaderView: View {
    
    @StateObject private var model: WidgetsHeaderViewModel
    
    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        _model = StateObject(wrappedValue: WidgetsHeaderViewModel(spaceId: spaceId, onSpaceSelected: onSpaceSelected))
    }
    
    var body: some View {
        Button {
            model.onTapSpaceSettings()
        } label: {
            PageNavigationHeader {
                HStack(spacing: 12) {
                    IconView(icon: model.spaceIcon)
                        .frame(width: 32, height: 32)
                    VStack(alignment: .leading, spacing: 0) {
                        AnytypeText(model.spaceName, style: .uxTitle2Semibold)
                            .foregroundStyle(Color.Text.primary)
                            .lineLimit(1)
                        if model.sharedSpace, !model.isOneToOne {
                            AnytypeText(model.spaceMembers, style: .relation2Regular)
                                .foregroundStyle(Color.Control.transparentSecondary)
                        } else {
                            AnytypeText(model.spaceUxType, style: .relation2Regular)
                                .foregroundStyle(Color.Control.transparentSecondary)
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
            .background {
                HomeBlurEffectView(direction: .topToBottom)
                    .ignoresSafeArea()
            }
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .task {
            await model.startSubscriptions()
        }
    }
}
