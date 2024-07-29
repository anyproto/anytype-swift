import Services
import SwiftUI


extension P2PStatusInfo {
    static func `default`(spaceId: String) -> P2PStatusInfo {
        var info = P2PStatusInfo()
        info.status = .UNRECOGNIZED(1337)
        info.spaceID = spaceId
        return info
    }
}

// Texts
extension P2PStatusInfo {
    var networkTitle: String {
        switch status {
        case .notConnected, .UNRECOGNIZED:
            Loc.p2PConnecting
        case .notPossible, .connected:
            Loc.p2PConnection
        }
    }
    
    var networkSubtitle: String {
        switch status {
        case .notConnected, .UNRECOGNIZED:
            ""
        case .notPossible:
            Loc.SyncStatus.P2P.restricted
        case .connected:
            Loc.devicesConnected(Int(devicesCounter))
        }
    }
}

// MARK: - NetworkIconProvider
extension P2PStatusInfo: NetworkIconProvider {
    var icon: ImageAsset {
        switch self.status {
        case .notConnected, .notPossible, .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncP2pDefault
        case .connected:
            ImageAsset.SyncStatus.syncP2pConnected
        }
    }
    
    var background: NetworkIconBackground {
        switch status {
        case .notConnected:
            .animation(start: .Shape.secondary, end: .Shape.secondary.opacity(0.5))
        case .notPossible, .UNRECOGNIZED:
            .static(.Shape.secondary)
        case .connected:
            .static(.Light.green)
        }
    }
}
