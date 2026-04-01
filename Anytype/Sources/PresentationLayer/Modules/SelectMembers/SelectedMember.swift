import Foundation
import Services

struct SelectedMember: Equatable, Hashable {
    let identity: String
    let role: ParticipantPermissions
}
