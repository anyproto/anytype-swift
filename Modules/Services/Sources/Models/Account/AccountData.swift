import ProtobufMessages

public struct AccountData {
    
    public let id: BlockId
    public let name: String
    public let avatar: Anytype_Model_Account.Avatar
    public let config: AccountConfiguration
    public var status: AccountStatus
    public let info: AccountInfo
    
    public static var empty: AccountData {
        AccountData(id: "", name: "", avatar: .init(), config: .empty, status: .active, info: .empty)
    }
}

public extension Anytype_Model_Account {
    func asModel() throws -> AccountData {
        AccountData(
            id: id,
            name: name,
            avatar: avatar,
            config: config.asModel,
            status: try status.asModel(),
            info: info.asModel
        )
    }
}
