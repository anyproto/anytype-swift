import ProtobufMessages
import BlocksModels

struct AccountData {
    var id: BlockId
    var name: String
    var avatar: Anytype_Model_Account.Avatar
    var config: AccountConfiguration
    var status: AccountStatus
    var info: AccountInfo
    
    static var empty: AccountData {
        AccountData(id: "", name: "", avatar: .init(), config: .empty, status: .active, info: .empty)
    }
}

extension Anytype_Model_Account {
    var asModel: AccountData {
        AccountData(
            id: id,
            name: name,
            avatar: avatar,
            config: config.asModel,
            status: status.asModel ?? .active,
            info: info.asModel
        )
    }
}
