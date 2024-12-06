import ProtobufMessages

public struct AccountConfiguration: Sendable, Equatable {    
    let enableSpaces: Bool
    let enableDataview: Bool
    let enableDebug: Bool
    let enablePrereleaseChannel: Bool
    
    static let empty = AccountConfiguration(
        enableSpaces: false,
        enableDataview: false,
        enableDebug: false,
        enablePrereleaseChannel: false
    )
}

extension Anytype_Rpc.Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug,
            enablePrereleaseChannel: enablePrereleaseChannel
        )
    }
}

extension Anytype_Model_Account.Config {
    var asModel: AccountConfiguration {
        AccountConfiguration(
            enableSpaces: enableSpaces,
            enableDataview: enableDataview,
            enableDebug: enableDebug,
            enablePrereleaseChannel: enablePrereleaseChannel
        )
    }
}
