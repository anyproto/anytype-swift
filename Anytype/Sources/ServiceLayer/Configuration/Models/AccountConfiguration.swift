import ProtobufMessages

struct AccountConfiguration {    
    let enableSpaces: Bool
    let enableDataview: Bool
    let enableDebug: Bool
    let enableReleaseChannelSwitch: Bool
    
    static let empty = AccountConfiguration(
        enableSpaces: false,
        enableDataview: false,
        enableDebug: false,
        enableReleaseChannelSwitch: false
    )
}

extension Anytype_Rpc.Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug,
            enableReleaseChannelSwitch: enableReleaseChannelSwitch
        )
    }
}

extension Anytype_Model_Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug,
            enableReleaseChannelSwitch: enableReleaseChannelSwitch
        )
    }
}
