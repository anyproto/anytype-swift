import Foundation
import SwiftUI

struct InviteLinkView: View {
    
    let invite: URL?
    let limitTitle: String
    let activeShareLink: Bool
    let onUpdateLink: () -> Void
    let onShareInvite: () -> Void
    let onCopyLink: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText(Loc.SpaceShare.Invite.title, style: .uxTitle1Semibold, color: .Text.primary)
                Spacer()
                Button {
                    onUpdateLink()
                } label: {
                    IconView(icon: .asset(.X24.replace))
                        .frame(width: 28, height: 28)
                }
            }
            Spacer.fixedHeight(8)
            AnytypeText(Loc.SpaceShare.Invite.description, style: .uxCalloutRegular, color: .Text.primary)
            Spacer.fixedHeight(8)
            Button {
                onCopyLink()
            } label: {
                AnytypeText(invite?.absoluteString ?? "", style: .uxCalloutRegular, color: .Text.secondary)
                    .lineLimit(1)
                    .frame(height: 48)
                    .newDivider()
            }
            .disabled(!activeShareLink)
            Spacer.fixedHeight(14)
            AnytypeText(limitTitle, style: .relation3Regular, color: .Text.secondary)
            Spacer.fixedHeight(13)
            StandardButton(Loc.SpaceShare.Invite.button, style: .primaryLarge) {
                onShareInvite()
            }
            .disabled(!activeShareLink)
        }
        .padding(20)
        .background(Color.Background.secondary)
        .cornerRadius(16, style: .continuous)
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
        .shadow(radius: 16)
        .ignoresSafeArea()
    }
}
