import Foundation
import ProtobufMessages
import AnytypeCore

public protocol HistoryVersionsServiceProtocol: Sendable {
    func getVersions(objectId: String, lastVersionId: String) async throws -> [VersionHistory]
    func showVersion(objectId: String, versionId: String) async throws -> ObjectViewModel
    func diffVersions(
        objectId: String,
        spaceId: String,
        currentVersionId: String,
        previousVersionId: String
    ) async throws -> VersionHistoryDiff
    func setVersion(objectId: String, versionId: String) async throws
}

final class HistoryVersionsService: HistoryVersionsServiceProtocol {
    
    public func getVersions(objectId: String, lastVersionId: String) async throws -> [VersionHistory] {
        let response = try await ClientCommands.historyGetVersions(.with {
            $0.objectID = objectId
            $0.limit = Constants.limit
            $0.lastVersionID = lastVersionId
            $0.notIncludeVersion = true
        }).invoke()
        return response.versions
    }
    
    public func showVersion(objectId: String, versionId: String) async throws -> ObjectViewModel {
        let response = try await ClientCommands.historyShowVersion(.with {
            $0.objectID = objectId
            $0.versionID = versionId
        }).invoke()
        return response.objectView
    }
    
    public func diffVersions(
        objectId: String,
        spaceId: String,
        currentVersionId: String,
        previousVersionId: String
    ) async throws -> VersionHistoryDiff {
        let response = try await ClientCommands.historyDiffVersions(.with {
            $0.objectID = objectId
            $0.spaceID = spaceId
            $0.currentVersion = currentVersionId
            $0.previousVersion = previousVersionId
        }).invoke()
        return VersionHistoryDiff(events: response.historyEvents, objectView: response.objectView)
    }
    
    public func setVersion(objectId: String, versionId: String) async throws {
        try await ClientCommands.historySetVersion(.with {
            $0.objectID = objectId
            $0.versionID = versionId
        }).invoke()
    }
}

extension HistoryVersionsService {
    enum Constants {
        static let limit: Int32 = 300
    }
}
