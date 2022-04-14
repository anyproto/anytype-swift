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
    
    init(details: ObjectDetails) {        
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImageHash
        blockId = details.id
    }
    
}
