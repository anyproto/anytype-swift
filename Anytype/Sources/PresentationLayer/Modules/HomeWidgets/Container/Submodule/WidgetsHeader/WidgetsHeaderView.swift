import Foundation
import SwiftUI

struct WidgetsHeaderView: View {
    
    @StateObject private var model: WidgetsHeaderViewModel
    
    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        _model = StateObject(wrappedValue: WidgetsHeaderViewModel(spaceId: spaceId, onSpaceSelected: onSpaceSelected))
    }
    
    var body: some View {
        PageNavigationHeader {
            HStack(spacing: 12) {
                IconView(icon: model.spaceIcon)
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(model.spaceName, style: .uxTitle2Semibold)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    if model.sharedSpace {
                        AnytypeText(model.spaceMembers, style: .relation2Regular)
                            .foregroundColor(.Control.transparentActive)
                    } else {
                        AnytypeText(model.spaceAccessType, style: .relation2Regular)
                            .foregroundColor(.Control.transparentActive)
                    }
                }
                Spacer()
            }
            .fixTappableArea()
            .onTapGesture {
                model.onTapSpaceSettings()
            }
        } rightView: {
            if model.isOwner {
                Image(asset: .X24.spaceSettings)
                    .foregroundStyle(Color.Control.transparentActive)
                    .onTapGesture {
                        model.onTapSpaceSettings()
                    }
            }
        }
        .task {
            await model.startSubscriptions()
        }
    }
}
