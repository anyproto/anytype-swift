import Services
import Combine
import ProtobufMessages

final class SyncStatusStorageMock: SyncStatusStorageProtocol, @unchecked Sendable {
    
    static let shared = SyncStatusStorageMock()
    
    @Published private var publishedInfo: SpaceSyncStatusInfo = .default(spaceId: "")
    var infoToReturn = Services.SpaceSyncStatusInfo.mockArray()
    
    func statusPublisher(spaceId: String) -> AnyPublisher<Services.SpaceSyncStatusInfo, Never> {
        Task.detached { [infoToReturn] in
            while true {
                for info in infoToReturn {
                    Task { @MainActor [weak self] in self?.publishedInfo = info }
                    try await Task.sleep(seconds: 2)
                }
            }
        }
        
        return $publishedInfo.eraseToAnyPublisher()
    }
    
    func startSubscription() {
       fatalError()
    }
    
    func stopSubscriptionAndClean() {
        fatalError()
    }
}

extension SpaceSyncStatusInfo {
    static func mockArray(network: Anytype_Event.Space.Network = .anytype) -> [Services.SpaceSyncStatusInfo] {
        [
            .mock(network: network, status: .offline),
            .mock(network: network, status: .syncing),
            .mock(network: network, status: .synced),
            .mock(network: network, status: .error),
        ]
    }

    static func mock(
        network: Anytype_Event.Space.Network = .anytype,
        status: Anytype_Event.Space.Status = .offline
    ) -> Services.SpaceSyncStatusInfo {
        var mock = Services.SpaceSyncStatusInfo.init()
        mock.id = "1337"
        mock.status = status
        mock.error = .incompatibleVersion
        mock.network = network
        mock.syncingObjectsCounter = 10
        return mock
    }
}
