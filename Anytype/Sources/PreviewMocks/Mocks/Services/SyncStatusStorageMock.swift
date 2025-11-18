import Services
import Combine
import ProtobufMessages

final class SyncStatusStorageMock: SyncStatusStorageProtocol, @unchecked Sendable {
    
    static let shared = SyncStatusStorageMock()
    
    @Published private var publishedInfo: SpaceSyncStatusInfo = .default(spaceId: "")
    var infoToReturn = SpaceSyncStatusInfo.mockArray()
    
    func statusPublisher(spaceId: String) -> AnyPublisher<SpaceSyncStatusInfo, Never> {
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
    
    func allSpacesStatusPublisher() -> AnyPublisher<[SpaceSyncStatusInfo], Never> {
        return $publishedInfo
            .map { [$0] }
            .eraseToAnyPublisher()
    }
    
    func startSubscription() async {
       // Mock implementation - no-op
    }
    
    func stopSubscriptionAndClean() async {
        // Mock implementation - no-op
    }
}

extension SpaceSyncStatusInfo {
    static func mockArray(network: Anytype_Event.Space.Network = .anytype) -> [SpaceSyncStatusInfo] {
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
    ) -> SpaceSyncStatusInfo {
        var mock = SpaceSyncStatusInfo.init()
        mock.id = "1337"
        mock.status = status
        mock.error = .incompatibleVersion
        mock.network = network
        mock.syncingObjectsCounter = 10
        return mock
    }
}
