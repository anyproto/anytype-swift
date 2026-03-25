import Foundation
import Services

struct SelectedMember: Equatable {
    let identity: String
    let role: ParticipantPermissions
}
