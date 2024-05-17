import Services
import Foundation
import Combine

final class FileLimitsStorageMock:  FileLimitsStorageProtocol {
    static let shared = FileLimitsStorageMock()
    
    @Published var usageInfoMockedValue: Services.NodeUsageInfo = .mock()
    var nodeUsage: AnyPublisher<Services.NodeUsageInfo, Never> { $usageInfoMockedValue.eraseToAnyPublisher() }
    
}

extension Services.NodeUsageInfo {
    static let MB: Int64 = 1024*1024
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
    static let MB: Int64 = 1024*1024
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
