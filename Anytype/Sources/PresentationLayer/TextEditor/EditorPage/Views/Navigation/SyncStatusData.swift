import Services

struct SyncStatusData {
    let status: SyncStatus
    let networkId: String
    
    var description: String {
        switch status {
        case .unknown:
            return Loc.initializingSync
        case .offline:
            return Loc.anytypeNodeIsNotConnected
        case .syncing:
            return Loc.downloadingOrUploadingDataToSomeNode
        case .synced:
            return syncedDescription
        case .failed:
            return Loc.failedToSyncTryingAgain
        case .incompatibleVersion:
            return Loc.Sync.Status.Version.Outdated.description
        }
    }
    
    private var syncedDescription: String {
        if networkId == Constants.anytypeNetworkId {
            return Loc.SyncStatus.Synced.Anytype.description
        } else if networkId == Constants.anytypeStagingNetworkId {
            return Loc.SyncStatus.Synced.AnytypeStaging.description
        } else if networkId.isEmpty {
            return Loc.SyncStatus.Synced.LocalOnly.description
        } else {
            return Loc.SyncStatus.Synced.SelfHosted.description
        }
    }
}

extension SyncStatusData {
    enum Constants {
        static let anytypeNetworkId = "N83gJpVd9MuNRZAuJLZ7LiMntTThhPc6DtzWWVjb1M3PouVU"
        static let anytypeStagingNetworkId = "N9DU6hLkTAbvcpji3TCKPPd3UQWKGyzUxGmgJEyvhByqAjfD"
    }
    
    static let empty = SyncStatusData(status: .unknown, networkId: "")
}
