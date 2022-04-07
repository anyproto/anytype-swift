import ProtobufMessages
import BlocksModels

struct AccountData {
    let id: BlockId
    let name: String
    let avatar: Anytype_Model_Account.Avatar
    let config: AccountConfiguration
    let status: AccountStatus
    
    static var empty: AccountData {
        AccountData(id: "", name: "", avatar: .init(), config: .empty, status: .active)
    }
}

extension Anytype_Model_Account {
    var asModel: AccountData {
        AccountData(
            id: id,
            name: name,
            avatar: avatar,
            config: config.asModel,
            status: status.asModel ?? .active
        )
    }
}
