import Foundation
import SwiftUI

struct SpaceShareParticipant: View {
    
    let participant: Participant
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: participant.icon)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(participant.name, style: .uxTitle2Medium, color: .Text.primary)
                AnytypeText(participant.permission.title, style: .relation2Regular, color: .Text.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 9)
        .frame(height: 72)
    }
}
