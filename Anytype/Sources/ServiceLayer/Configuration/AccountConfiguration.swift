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

extension AccountConfiguration {
    init(config: Anytype_Rpc.Account.Config) {
        self.enableSpaces = config.enableSpaces
        self.enableDataview = config.enableDataview
        self.enableDebug = config.enableDebug
        self.enableReleaseChannelSwitch = config.enableReleaseChannelSwitch
    }
    
    init(config: Anytype_Model_Account.Config) {
        self.enableSpaces = config.enableSpaces
        self.enableDataview = config.enableDataview
        self.enableDebug = config.enableDebug
        self.enableReleaseChannelSwitch = config.enableReleaseChannelSwitch
    }
}
