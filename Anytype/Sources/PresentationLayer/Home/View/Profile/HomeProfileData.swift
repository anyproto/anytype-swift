import AnytypeCore
import BlocksModels

struct HomeProfileData {
    
    let name: String
    let avatarId: Hash?
    let blockId: AnytypeId
    
}
            
extension HomeProfileData {
    
    static let defaultName = "Username"
    
}

extension HomeProfileData {
    
    init?(details: ObjectDetails) {
        guard let id = details.id.asAnytypeId else { return nil }
        
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImageHash
        blockId = id
    }
    
}
