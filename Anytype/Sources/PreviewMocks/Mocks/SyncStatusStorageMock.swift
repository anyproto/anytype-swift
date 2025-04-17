import Services
import Combine
import ProtobufMessages

final class SyncStatusStorageMock: SyncStatusStorageProtocol, @unchecked Sendable {
    
    static let shared = SyncStatusStorageMock()
    
    @Published private var publishedInfo: SyncStatusInfo = .default(spaceId: "")
    var infoToReturn = Services.SyncStatusInfo.mockArray()
    
    func statusPublisher(spaceId: String) -> AnyPublisher<Services.SyncStatusInfo, Never> {
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

extension SyncStatusInfo {
    static func mockArray(network: Anytype_Event.Space.Network = .anytype) -> [Services.SyncStatusInfo] {
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
    ) -> Services.SyncStatusInfo {
        var mock = Services.SyncStatusInfo.init()
        mock.id = "1337"
        mock.status = status
        mock.error = .incompatibleVersion
        mock.network = network
        mock.syncingObjectsCounter = 10
        return mock
    }
}
