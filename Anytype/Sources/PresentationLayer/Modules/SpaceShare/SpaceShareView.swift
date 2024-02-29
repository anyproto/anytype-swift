import Foundation
import SwiftUI

struct SpaceShareView: View {
    
    @StateObject var model: SpaceShareViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceShare.title)
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        SectionHeaderView(title: Loc.SpaceShare.membersSection)
                        ForEach(model.rows) { participant in
                            SpaceShareParticipantView(participant: participant)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .safeAreaInset(edge: .bottom) {
                    inviteView
                }
            }
        }
        .anytypeShareView(item: $model.shareInviteLink)
        .snackbar(toastBarData: $model.toastBarData)
        .anytypeSheet(item: $model.requestAlertModel) { model in
            SpaceRequestView(model: model)
        }
        .anytypeSheet(item: $model.changeAccessAlertModel) { model in
            SpaceChangeAccessView(model: model)
        }
        .anytypeSheet(item: $model.removeParticipantAlertModel) { model in
            SpaceParticipantRemoveView(model: model)
        }
    }
    
    private var inviteView: some View {
        InviteLinkView(invite: model.inviteLink, limitTitle: model.limitTitle, activeShareLink: model.activeShareButton) {
            model.onUpdateLink()
        } onShareInvite: {
            model.onShareInvite()
        } onCopyLink: {
            model.onCopyLink()
        }
    }
}
