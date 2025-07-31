import SwiftUI

struct NewInviteLinkCoordinatorView: View {
    
    @StateObject private var model: NewInviteLinkCoordinatorViewModel
    
    init(data: SpaceShareData) {
        self._model = StateObject(wrappedValue: NewInviteLinkCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        NewInviteLinkView(
            data: model.data,
            output: model
        )
        .sheet(item: $model.shareInviteLink) { link in
            ActivityView(activityItems: [link])
        }
        .anytypeSheet(item: $model.qrCodeInviteLink) {
            QrCodeView(title: Loc.SpaceShare.Qr.title, data: $0.absoluteString, analyticsType: .inviteSpace)
        }
    }
}