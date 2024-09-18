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
    var networkTitle: String { Loc.p2PConnection }
    
    var networkSubtitle: String {
        switch status {
        case .notConnected, .UNRECOGNIZED:
            Loc.SyncStatus.P2P.notConnected
        case .notPossible, .restricted:
            Loc.SyncStatus.P2P.restricted
        case .connected:
            Loc.devicesConnected(Int(devicesCounter))
        }
    }
}

// MARK: - NetworkIconProvider
extension P2PStatusInfo: NetworkIconProvider {
    var iconData: NetworkIconData {
        switch self.status {
        case .notPossible, .restricted:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .System.red
            )
        case .notConnected, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .Button.active
            )
        case .connected:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .Dark.green
            )
        }
    }
    
    var background: NetworkIconBackground {
        switch status {
        case .notConnected:
            .animation(start: .Shape.secondary, end: .Shape.secondary.opacity(0.5))
        case .notPossible, .UNRECOGNIZED, .restricted:
            .static(.Light.red)
        case .connected:
            .static(.Light.green)
        }
    }
    
    var haveTapIndicatior: Bool {
        switch status {
        case .notConnected, .connected, .UNRECOGNIZED:
            return false
        case .notPossible, .restricted:
            return true
        }
    }
}
