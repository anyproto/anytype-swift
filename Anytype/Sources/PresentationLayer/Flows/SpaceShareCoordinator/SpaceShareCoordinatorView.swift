import Foundation
import SwiftUI
import Services

struct SpaceShareCoordinatorView: View {
    
    @StateObject private var model: SpaceShareCoordinatorViewModel
    
    init(data: SpaceShareData) {
        self._model = StateObject(wrappedValue: SpaceShareCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        SpaceShareView(data: model.data, output: model)
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
