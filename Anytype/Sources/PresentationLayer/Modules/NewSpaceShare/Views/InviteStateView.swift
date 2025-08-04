import SwiftUI
import Services
import Loc

struct InviteStateView: View {
    let invite: SpaceInvite?
    
    var body: some View {
        if let invite {
            switch invite.inviteType {
            case .member:
                content(icon: .X24.addMembers, title: Loc.Space.Invite.RequestAccess.title, subtitle: Loc.Space.Invite.RequestAccess.subtitle)
            case .withoutApprove:
                switch invite.permissions {
                case .reader:
                    content(icon: .X24.viewer, title: Loc.Space.Invite.ViewerAccess.title, subtitle: Loc.Space.Invite.ViewerAccess.subtitle)
                case .writer:
                    content(icon: .X24.editor, title: Loc.Space.Invite.EditorAccess.title, subtitle: Loc.Space.Invite.EditorAccess.subtitle)
                case .owner, .noPermissions, .UNRECOGNIZED, .none:
                    errorState
                }
            case .guest, .none, .UNRECOGNIZED:
                errorState
            }
        } else {
            content(icon: .X24.lock, title: Loc.Space.Invite.LinkDisabled.title, subtitle: Loc.Space.Invite.LinkDisabled.subtitle)
        }
    }
    
    var errorState: some View {
        content(icon: .X24.lock, title: Loc.Error.Common.title, subtitle: Loc.Content.Common.error)
    }
    
    private func content(icon: ImageAsset, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.Shape.transperentSecondary)
                    .frame(width: 48, height: 48)
                
                IconView(asset: icon)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(title, style: .previewTitle2Medium)
                    .lineLimit(1)
                    .foregroundColor(.Text.primary)
                
                AnytypeText(subtitle, style: .relation2Regular)
                    .lineLimit(1)
                    .foregroundColor(.Text.secondary)
            }
            
            Spacer()
        }
        .frame(height: 72)
    }
    
}
