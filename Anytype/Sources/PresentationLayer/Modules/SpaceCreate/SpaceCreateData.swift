import Foundation
import Services

struct SpaceCreateData: Equatable, Identifiable, Hashable {
    let sceneId: String
    let spaceUxType: SpaceUxType
    
    var id: Int { hashValue }
}
