import BlocksModels

struct HomeProfileData {
    private(set) var name = "Username"
    private(set) var avatarId: String?
    private(set) var blockId: BlockId = ""
    
    mutating func update(details: ObjectDetails) {
        name = details.name.isNotEmpty ? details.name : "Username"
        avatarId = details.iconImageHash?.value
        blockId = details.id
    }
}
