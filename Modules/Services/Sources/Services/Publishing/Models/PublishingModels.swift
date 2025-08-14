import Foundation
import ProtobufMessages


public struct PublishState: Sendable, Equatable, Hashable {
    public let spaceId: String
    public let objectId: String
    public let uri: String
    public let status: PublishStatus
    public let version: String
    public let timestamp: Date
    public let size: Int64
    public let joinSpace: Bool
    public let details: ObjectDetails
    
    init(from protobuf: Anytype_Rpc.Publishing.PublishState) {
        self.spaceId = protobuf.spaceID
        self.objectId = protobuf.objectID
        self.uri = protobuf.uri
        self.status = PublishStatus(from: protobuf.status)
        self.version = protobuf.version
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(protobuf.timestamp))
        self.size = protobuf.size
        self.joinSpace = protobuf.joinSpace
        self.details = (try? protobuf.details.toDetails()) ?? ObjectDetails(id: protobuf.objectID)
    }
}

public enum PublishStatus: Sendable {
    case created
    case published
    case unknown
    
    init(from protobuf: Anytype_Rpc.Publishing.PublishStatus) {
        switch protobuf {
        case .created:
            self = .created
        case .published:
            self = .published
        case .UNRECOGNIZED:
            self = .unknown
        }
    }
}

public enum PublishingServiceError: Error {
    case invalidUriFormat
    case publishingFailed(String)
}
