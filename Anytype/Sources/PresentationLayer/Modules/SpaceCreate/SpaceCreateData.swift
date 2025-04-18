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
        case .UNRECOGNIZED(_):
            return ""
        }
    }
}

extension SpaceUxType {
    var useCase: UseCase {
        switch self {
        case .chat: return .none
        case .data: return FeatureFlags.guideUseCaseForDataSpace ? .guideOnly : .empty
        default: return .empty
        }
    }
}
