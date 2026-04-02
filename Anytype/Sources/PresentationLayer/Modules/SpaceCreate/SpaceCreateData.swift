import Foundation
import Services
import AnytypeCore

enum ChannelType: Equatable, Hashable {
    case personal
    case group
}

struct SpaceCreateData: Equatable, Identifiable, Hashable {
    let spaceUxType: SpaceUxType
    let selectedContacts: [Contact]
    let channelType: ChannelType?

    init(spaceUxType: SpaceUxType, selectedContacts: [Contact] = [], channelType: ChannelType? = nil) {
        self.spaceUxType = spaceUxType
        self.selectedContacts = selectedContacts
        self.channelType = channelType
    }

    var id: Int { hashValue }

    var title: String {
        if channelType != nil {
            return Loc.SpaceCreate.Space.title
        }
        switch spaceUxType {
        case .chat:
            return Loc.SpaceCreate.Chat.title
        case .data:
            return Loc.SpaceCreate.Space.title
        case .stream:
            return Loc.SpaceCreate.Stream.title
        case .UNRECOGNIZED(_), .none, .oneToOne:
            return ""
        }
    }
}

extension SpaceUxType {
    var useCase: UseCase {
        switch self {
        case .chat, .stream: .chatSpace
        case .data: .dataSpaceMobile
        case .oneToOne, .none, .UNRECOGNIZED: .none
        }
    }
}
