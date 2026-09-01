import SwiftUI
import Services

struct UnifiedSearchPersonRow: Identifiable, Hashable {
    let identity: String
    // The representative participant object (scope/current space preferred)
    let participantObjectId: String
    let spaceId: String
    let title: String
    let globalName: String
    let icon: Icon
    // Shared channels, the person's own 1:1 not counted
    let sharedChannelCount: Int
    let hasOneToOne: Bool

    var id: String { identity }

    // Shared-channel count leads; a pure-DM contact falls back to the global
    // name, then a short identity fragment. (The create verb lives in the
    // focused listing - the row itself expands.)
    var caption: String? {
        switch sharedChannelCount {
        case 1:
            return Loc.UnifiedSearch.Person.memberInOneChannel
        case 2...:
            return Loc.UnifiedSearch.Person.memberInChannels(sharedChannelCount)
        default:
            if globalName.isNotEmpty { return globalName }
            return identity.isEmpty ? nil : String(identity.prefix(6)) + "…"
        }
    }
}
