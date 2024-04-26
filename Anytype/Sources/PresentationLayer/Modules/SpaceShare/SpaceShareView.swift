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
                        ForEach(model.participants) { participant in
                            SpaceShareParticipant(participant: participant)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                InviteLinkView(invite: model.inviteLink, limitTitle: model.limitTitle, activeShareLink: model.activeShareButton) {
                    model.onUpdateLink()
                } onShareInvite: {
                    model.onShareInvite()
                } onCopyLink: {
                    model.onCopyLink()
                }
            }
            .ignoresSafeArea()
        }
        .anytypeShareView(item: $model.shareInviteLink)
        .snackbar(toastBarData: $model.toastBarData)
    }
}
