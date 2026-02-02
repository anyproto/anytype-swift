import Foundation
import SwiftUI
import Services

struct SpaceShareCoordinatorView: View {

    @State private var model: SpaceShareCoordinatorViewModel

    init(data: SpaceShareData) {
        self._model = State(initialValue: SpaceShareCoordinatorViewModel(data: data))
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
            .sheet(isPresented: $model.presentSpacesManager) {
                SpacesManagerView()
            }
    }
}
