import Services


extension AccountData {
    var isInProdNetwork: Bool {
        info.networkId == NetworkIds.anytype
    }
}
