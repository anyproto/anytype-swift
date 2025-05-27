import SwiftUI

struct InviteLinkCoordinatorView: View {
    
    @StateObject private var model: InviteLinkCoordinatorViewModel
    
    init(data: SpaceShareData) {
        self._model = StateObject(wrappedValue: InviteLinkCoordinatorViewModel(data: data))
    }
    
    var body: some View {
        InviteLinkView(
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
