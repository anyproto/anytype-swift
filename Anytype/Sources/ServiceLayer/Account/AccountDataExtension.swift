import Services


extension AccountData {
    var isInProdOrStagingNetwork: Bool {
        info.networkId == NetworkIds.anytype || info.networkId == NetworkIds.anytypeStaging
    }
}
