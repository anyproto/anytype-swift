import Foundation
import SwiftUI

struct SpaceShareParticipantViewModel: Identifiable {
    let id: String
    let icon: Icon?
    let name: String
    let status: Status?
    let action: Action?
    
    enum Status {
        case normal(permission: String)
        case joining
        case declined
    }
    
    struct Action {
        let title: String
        let action: () -> Void
    }
}

struct SpaceShareParticipantView: View {
    
    let participant: SpaceShareParticipantViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: participant.icon)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(participant.name, style: .uxTitle2Medium, color: .Text.primary)
                status
            }
            Spacer()
            if let action = participant.action {
                StandardButton(.text(action.title), style: .secondarySmall, action: action.action)
            }
        }
        .lineLimit(1)
        .padding(.vertical, 9)
        .frame(height: 72)
    }
    
    @ViewBuilder
    private var status: some View {
        switch participant.status {
        case .normal(let permission):
            AnytypeText(permission, style: .relation3Regular, color: .Text.secondary)
        case .joining:
            AnytypeText(Loc.SpaceShare.Status.joining, style: .relation3Regular, color: .Dark.pink)
                .padding(.horizontal, 3)
                .background(Color.Light.pink)
                .cornerRadius(3, style: .continuous)
        case .declined:
            AnytypeText(Loc.SpaceShare.Status.declined, style: .relation3Regular, color: .Text.secondary)
        case .none:
            EmptyView()
        }
    }
}
