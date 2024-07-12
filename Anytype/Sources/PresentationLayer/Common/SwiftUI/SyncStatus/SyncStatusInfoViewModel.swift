import SwiftUI
import Services


final class SyncStatusInfoViewModel: ObservableObject {
    @Injected(\.syncStatusStorage)
    private var syncStatusStorage: SyncStatusStorageProtocol
    
    @Published var syncStatusInfo: SyncStatusInfo
    
    init(spaceId: String) {
        syncStatusInfo = .default(spaceId: spaceId)
        
        Task { await syncStatusStorage.statusPublisher(spaceId: spaceId).assign(to: &$syncStatusInfo) }
    }
    
}
