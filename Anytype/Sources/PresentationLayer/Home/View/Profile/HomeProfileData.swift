import AnytypeCore
import BlocksModels

struct HomeProfileData {
    
    let name: String
    let avatarId: String?
    let blockId: AnytypeID
    
}
            
extension HomeProfileData {
    
    static let defaultName = "Username"
    
}

extension HomeProfileData {
    
    init?(details: ObjectDetails) {
        guard let id = details.id.asAnytypeID else { return nil }
        
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImageHash?.value
        blockId = id
    }
    
}
