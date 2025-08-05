import SwiftUI
import Loc

struct InviteStateView: View {
    let richInviteType: SpaceRichIviteType?
    
    var body: some View {
        if let richInviteType {
            switch richInviteType {
            case .editor:
                content(icon: .X24.editor, title: Loc.Space.Invite.EditorAccess.title, subtitle: Loc.Space.Invite.EditorAccess.subtitle)
            case .viewer:
                content(icon: .X24.viewer, title: Loc.Space.Invite.ViewerAccess.title, subtitle: Loc.Space.Invite.ViewerAccess.subtitle)
            case .requestAccess:
                content(icon: .X24.addMembers, title: Loc.Space.Invite.RequestAccess.title, subtitle: Loc.Space.Invite.RequestAccess.subtitle)
            case .disabled:
                content(icon: .X24.lock, title: Loc.Space.Invite.LinkDisabled.title, subtitle: Loc.Space.Invite.LinkDisabled.subtitle)
            }
        } else {
            errorState
        }
    }
    
    private var errorState: some View {
        content(icon: .X24.lock, title: Loc.Error.Common.title, subtitle: Loc.Content.Common.error)
    }
    
    private func content(icon: ImageAsset, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.Shape.transperentSecondary)
                    .frame(width: 48, height: 48)
                
                Image(asset: icon)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(title, style: .previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                
                AnytypeText(subtitle, style: .relation2Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .frame(height: 72)
    }
    
}
