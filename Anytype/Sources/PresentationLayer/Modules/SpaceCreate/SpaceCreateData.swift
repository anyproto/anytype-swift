import Foundation
import Services

enum ChannelType: Equatable, Hashable {
    case personal
    case group
}

struct SpaceCreateData: Equatable, Identifiable, Hashable {
    let selectedContacts: [Contact]
    let channelType: ChannelType

    init(selectedContacts: [Contact] = [], channelType: ChannelType) {
        self.selectedContacts = selectedContacts
        self.channelType = channelType
    }

    var id: Int { hashValue }
}
