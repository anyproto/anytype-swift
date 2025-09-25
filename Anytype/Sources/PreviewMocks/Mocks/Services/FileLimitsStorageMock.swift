import Services
import Foundation
import Combine

final class FileLimitsStorageMock: FileLimitsStorageProtocol, @unchecked Sendable {
    nonisolated static let shared = FileLimitsStorageMock()
    
    nonisolated init() {}
    
    @Published var nodeUsageMockedValue: Services.NodeUsageInfo = .mock()
    var nodeUsage: AnyPublisher<Services.NodeUsageInfo, Never> { $nodeUsageMockedValue.eraseToAnyPublisher() }
    
}

let KB: Int64 = 1024
let MB: Int64 = KB*KB
let GB: Int64 = MB*KB

extension Services.NodeUsageInfo {
    static func mock(
        filesCount: Int64 = 10,
        cidsCount: Int64 =  5,
        bytesUsage: Int64 = 10*MB,
        bytesLeft: Int64 = 90*MB,
        bytesLimit: Int64 = 100*MB,
        localBytesUsage: Int64 = 10*MB,
        spaces: [SpaceUsage] = [.mock()]
    ) -> Services.NodeUsageInfo {
        Services.NodeUsageInfo(
            node: NodeUsage(
                filesCount: filesCount,
                cidsCount: cidsCount,
                bytesUsage: bytesUsage,
                bytesLeft: bytesLeft,
                bytesLimit: bytesLimit,
                localBytesUsage: localBytesUsage
            ),
            spaces: spaces
        )
    }
}


extension SpaceUsage {
    static func mock(
        spaceId: String = UUID().uuidString,
        filesCount: Int64 = 10,
        cidsCount: Int64 = 5,
        bytesUsage: Int64 = 10*MB
    ) -> SpaceUsage {
        SpaceUsage(
            spaceID: spaceId,
            filesCount: filesCount,
            cidsCount: cidsCount,
            bytesUsage: bytesUsage
        )
    }
}
