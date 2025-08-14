import SwiftUI
import Services


@MainActor
final class SyncStatusInfoViewModel: ObservableObject {
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: any SyncStatusStorageProtocol
    @Injected(\.p2pStatusStorage)
    private var p2pStatusStorage: any P2PStatusStorageProtocol
    
    @Published var syncStatusInfo: SpaceSyncStatusInfo
    @Published var p2pStatusInfo: P2PStatusInfo
    
    init(spaceId: String) {
        syncStatusInfo = .default(spaceId: spaceId)
        p2pStatusInfo = .default(spaceId: spaceId)
        
        syncStatusStorage.statusPublisher(spaceId: spaceId).receiveOnMain().assign(to: &$syncStatusInfo)
        p2pStatusStorage.statusPublisher(spaceId: spaceId).receiveOnMain().assign(to: &$p2pStatusInfo)
    }
    
    func onNetworkInfoTap() {
        AppLinks.storeLink.flatMap { UIApplication.shared.open($0) }
    }
    
    func onP2PTap() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
