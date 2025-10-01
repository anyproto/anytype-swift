import Foundation
import Services
import AnytypeCore

struct SpaceCreateData: Equatable, Identifiable, Hashable {
    let spaceUxType: SpaceUxType
    
    var id: Int { hashValue }
    
    var title: String {
        switch spaceUxType {
        case .chat:
            return Loc.SpaceCreate.Chat.title
        case .data:
            return Loc.SpaceCreate.Space.title
        case .stream:
            return Loc.SpaceCreate.Stream.title
        case .UNRECOGNIZED(_), .none:
            return ""
        }
    }
}

extension SpaceUxType {
    var useCase: UseCase {
        switch self {
        case .chat, .stream: return .chatSpace
        case .data: return FeatureFlags.guideUseCaseForDataSpace ? .guideOnly : .dataSpaceMobile
        default: return .none
        }
    }
}
