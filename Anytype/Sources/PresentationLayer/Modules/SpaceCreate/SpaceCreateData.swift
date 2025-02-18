import Foundation
import Services

struct SpaceCreateData: Equatable, Identifiable, Hashable {
    let sceneId: String
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
    
    var nameTitle: String {
        switch spaceUxType {
        case .chat:
            return Loc.SpaceCreate.Chat.Name.title
        case .data:
            return Loc.SpaceCreate.Space.Name.title
        case .stream:
            return Loc.SpaceCreate.Stream.Name.title
        case .UNRECOGNIZED(_):
            return ""
        }
    }
    
    var nameDescription: String? {
        switch spaceUxType {
        case .stream:
            return Loc.SpaceCreate.Stream.Name.description
        default:
            return nil
        }
    }
}
