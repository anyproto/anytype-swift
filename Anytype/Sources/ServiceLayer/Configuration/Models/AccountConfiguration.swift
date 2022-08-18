import ProtobufMessages

struct AccountConfiguration {    
    let enableSpaces: Bool
    let enableDataview: Bool
    let enableDebug: Bool
    
    static let empty = AccountConfiguration(
        enableSpaces: false,
        enableDataview: false,
        enableDebug: false
    )
}

extension Anytype_Rpc.Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug
        )
    }
}

extension Anytype_Model_Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug
        )
    }
}
