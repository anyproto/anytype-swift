import Foundation
import SwiftUI
import Services
import AnytypeCore

struct SpaceShareCoordinatorView: View {
    
    @StateObject private var model: SpaceShareCoordinatorViewModel
    
    init(data: SpaceShareData) {
        self._model = StateObject(wrappedValue: SpaceShareCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        Group {
            if FeatureFlags.newSpaceMembersFlow {
                NewSpaceShareView(data: model.data, output: model)
            } else {
                SpaceShareView(data: model.data) {
                    model.onMoreInfoSelected()
                }
            }
        }
        .sheet(isPresented: $model.showMoreInfo) {
            SpaceMoreInfoView()
        }
        .sheet(item: $model.shareInviteLink) { link in
            ActivityView(activityItems: [link])
        }
        .anytypeSheet(item: $model.qrCodeInviteLink) {
            QrCodeView(title: Loc.joinSpace, data: $0.absoluteString, analyticsType: .inviteSpace, route: .inviteLink)
        }
    }
}
