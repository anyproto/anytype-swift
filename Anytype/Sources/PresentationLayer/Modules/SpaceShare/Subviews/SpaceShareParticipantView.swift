import Foundation
import SwiftUI

struct SpaceShareParticipantViewModel: Identifiable {
    let id: String
    let icon: Icon?
    let name: String
    let status: Status?
    
    enum Status {
        case normal(permission: String)
        case joining
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
        }
        .padding(.vertical, 9)
        .frame(height: 72)
    }
    
    @ViewBuilder
    private var status: some View {
        switch participant.status {
        case .normal(let permission):
            AnytypeText(permission, style: .relation2Regular, color: .Text.secondary)
        case .joining:
            AnytypeText("Requested", style: .relation3Regular, color: .Dark.pink)
                .padding(.horizontal, 3)
                .background(Color.Light.pink)
                .cornerRadius(3, style: .continuous)
        case .none:
            EmptyView()
        }
    }
}
