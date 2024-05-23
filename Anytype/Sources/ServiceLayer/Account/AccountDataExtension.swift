import Services


extension AccountData {
    var isInAnytypeNetwork: Bool {
        info.networkId == NetworkIds.anytype
    }
}
