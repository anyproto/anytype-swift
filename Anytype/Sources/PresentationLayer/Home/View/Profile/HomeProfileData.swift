import BlocksModels

struct HomeProfileData {
    private static let defaultName = "Username"
    
    let name: String
    let avatarId: String?
    let blockId: BlockId
    
    static let empty: HomeProfileData = HomeProfileData(name: Self.defaultName, avatarId: nil, blockId: "")
}
            
extension HomeProfileData {
    init(details: ObjectDetails) {
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImageHash?.value
        blockId = details.id
    }
}
