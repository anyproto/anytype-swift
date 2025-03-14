import Services


extension AccountData {
    var allowMembership: Bool {
        #if DEBUG || RELEASE_NIGHTLY || RELEASE_ANYTYPE
            return isInProdOrStagingNetwork
        #else
            return false
        #endif
    }
    
    private var isInProdOrStagingNetwork: Bool {
        info.networkId == NetworkIds.anytype || info.networkId == NetworkIds.anytypeStaging
    }
}
