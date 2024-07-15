import SwiftUI
import Services


final class SyncStatusInfoViewModel: ObservableObject {
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: SyncStatusStorageProtocol
    @Injected(\.p2pStatusStorage)
    private var p2pStatusStorage: P2PStatusStorageProtocol
    
    @Published var syncStatusInfo: SyncStatusInfo
    @Published var p2pStatusInfo: P2PStatusInfo
    
    init(spaceId: String) {
        syncStatusInfo = .default(spaceId: spaceId)
        p2pStatusInfo = .default(spaceId: spaceId)
        
        Task { @MainActor in await syncStatusStorage.statusPublisher(spaceId: spaceId).assign(to: &$syncStatusInfo) }
        Task { @MainActor in await p2pStatusStorage.statusPublisher(spaceId: spaceId).assign(to: &$p2pStatusInfo) }
    }    
}
