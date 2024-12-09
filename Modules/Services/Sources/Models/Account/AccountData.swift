import ProtobufMessages

public struct AccountData: Sendable, Equatable {
    
    public let id: String
    public let config: AccountConfiguration
    public var status: AccountStatus
    public let info: AccountInfo
    
    public static var empty: AccountData {
        AccountData(id: "", config: .empty, status: .active, info: .empty)
    }
}

public extension Anytype_Model_Account {
    func asModel() throws -> AccountData {
        AccountData(
            id: id,
            config: config.asModel,
            status: try status.asModel(),
            info: info.asModel
        )
    }
}
