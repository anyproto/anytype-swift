import Foundation
import SwiftUI

struct InviteLinkView: View {
    
    let invite: URL?
    let canDeleteLink: Bool
    let onShareInvite: () -> Void
    let onCopyLink: () -> Void
    let onDeleteSharingLink: () -> Void
    let onGenerateInvite: () async throws -> Void
    let onShowQrCode: () -> Void
    
    var body: some View {
        Group {
            if invite.isNotNil {
                linkContent
            } else {
                emptyLinkContent
            }
        }
        .padding(20)
        .background(Color.Background.secondary)
        .cornerRadius(16, style: .continuous)
        .padding(.horizontal, 16)
        .padding(.vertical, 36)
        .shadow(radius: 16)
    }
    
    var linkContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText(Loc.SpaceShare.Invite.title, style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        onDeleteSharingLink()
                    } label: {
                        Text(Loc.SpaceShare.DeleteSharingLink.title)
                    }
                    .disabled(!canDeleteLink)
                } label: {
                    IconView(icon: .asset(.X24.more))
                        .frame(width: 24, height: 24)
                }
            }
            Spacer.fixedHeight(4)
            Button {
                onCopyLink()
            } label: {
                AnytypeText(invite?.absoluteString ?? "", style: .uxCalloutRegular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
                    .frame(height: 48)
                    .newDivider()
            }
            Spacer.fixedHeight(10)
            AnytypeText(Loc.SpaceShare.Invite.description, style: .relation3Regular)
                .foregroundColor(.Text.secondary)
            Spacer.fixedHeight(20)
            StandardButton(Loc.SpaceShare.Invite.share, style: .primaryLarge) {
                onShareInvite()
            }
            Spacer.fixedHeight(10)
            StandardButton(Loc.SpaceShare.Qr.button, style: .secondaryLarge) {
                onShowQrCode()
            }
        }
    }
    
    var emptyLinkContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.SpaceShare.Invite.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(Loc.SpaceShare.Invite.empty, style: .calloutRegular)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(12)
            AsyncStandardButton(text: Loc.SpaceShare.Invite.generate, style: .primaryLarge) {
                try await onGenerateInvite()
            }
        }
    }
}
