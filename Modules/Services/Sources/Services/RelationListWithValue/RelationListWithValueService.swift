import Foundation
import ProtobufMessages

public protocol RelationListWithValueServiceProtocol: AnyObject {
    func relationListWithValue(_ value: String, spaceId: String) async throws -> [String]
}

final class RelationListWithValueService: RelationListWithValueServiceProtocol {
    func relationListWithValue(_ value: String, spaceId: String) async throws -> [String] {
        let result = try await ClientCommands.relationListWithValue(.with {
            $0.spaceID = spaceId
            $0.value = value.protobufValue
        }).invoke()
        return result.list.map { $0.relationKey }
    }
}
