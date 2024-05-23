import Services


extension AccountData {
    var isInProdOrStageingNetwork: Bool {
        info.networkId == NetworkIds.anytype || info.networkId == NetworkIds.anytypeStaging
    }
}
