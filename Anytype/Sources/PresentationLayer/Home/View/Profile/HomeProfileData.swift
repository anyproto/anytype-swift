import BlocksModels

struct HomeProfileData {
    private static let defaultName = "Username"
    
    private(set) var name = Self.defaultName
    private(set) var avatarId: String?
    private(set) var blockId: BlockId = ""
    
    mutating func update(details: ObjectDetails) {
        name = details.name.isNotEmpty ? details.name : Self.defaultName
        avatarId = details.iconImageHash?.value
        blockId = details.id
    }
}
