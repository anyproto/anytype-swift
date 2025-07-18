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
        case .notConnected:
            Loc.SyncStatus.P2P.notConnected
        case .notPossible, .UNRECOGNIZED:
            Loc.SyncStatus.P2P.notPossible
        case .connected:
            Loc.devicesConnected(Int(devicesCounter))
        case .restricted:
            Loc.SyncStatus.P2P.restricted
        }
    }
}

// MARK: - NetworkIconProvider
extension P2PStatusInfo: NetworkIconProvider {
    var iconData: NetworkIconData {
        switch self.status {
        case .notConnected, .notPossible, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .Control.secondary
            )
        case .connected:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .Dark.green
            )
        case .restricted:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncP2p,
                color: .Pure.red
            )
        }
    }

    var background: NetworkIconBackground {
        switch status {
        case .notConnected, .notPossible, .UNRECOGNIZED:
            .animation(start: .Shape.secondary, end: .Shape.secondary.opacity(0.5))
        case .connected:
            .static(.Light.green)
        case .restricted:
            .static(.Light.red)
        }
    }

    var haveTapIndicatior: Bool {
        switch status {
        case .notConnected, .connected, .notPossible, .UNRECOGNIZED:
            return false
        case .restricted:
            return true
        }
    }
}
