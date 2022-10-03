import AnytypeCore
import BlocksModels

struct HomeProfileData {
    
    let name: String
    let avatarId: Hash?
    let blockId: BlockId
    
}
            
extension HomeProfileData {
    
    static let defaultName = "Username"
    
}

extension HomeProfileData {
    
    init(details: ObjectDetails) {        
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImage
        blockId = details.id
    }
    
}
