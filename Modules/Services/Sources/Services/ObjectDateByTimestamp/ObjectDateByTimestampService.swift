import Foundation
import ProtobufMessages

public protocol ObjectDateByTimestampServiceProtocol: AnyObject, Sendable {
    func objectDateByTimestamp(_ timestamp: Double, spaceId: String) async throws -> ObjectDetails
}

final class ObjectDateByTimestampService: ObjectDateByTimestampServiceProtocol, Sendable {
    func objectDateByTimestamp(_ timestamp: Double, spaceId: String) async throws -> ObjectDetails {
        let result = try await ClientCommands.objectDateByTimestamp(.with {
            $0.spaceID = spaceId
            $0.timestamp = Int64(timestamp)
        }).invoke()
        return try result.details.toDetails()
    }
}
