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
                
                InviteLinkView(invite: model.inviteLink, left: model.left) {
                    model.onUpdateLink()
                } onShareInvite: {
                    model.onShareInvite()
                }
            }
        }
        .anytypeShareView(item: $model.shareInviteLink)
    }
}
