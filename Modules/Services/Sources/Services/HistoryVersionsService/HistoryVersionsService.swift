import Foundation
import ProtobufMessages

public protocol HistoryVersionsServiceProtocol: Sendable {
    func getVersions(objectId: String) async throws -> [VersionHistory]
}

final class HistoryVersionsService: HistoryVersionsServiceProtocol {
    
    public func getVersions(objectId: String) async throws -> [VersionHistory] {
        let response = try await ClientCommands.historyGetVersions(.with {
            $0.objectID = objectId
            $0.limit = Constants.limit
        }).invoke()
        return response.versions
    }
}

extension HistoryVersionsService {
    enum Constants {
        static let limit: Int32 = 300
    }
}
