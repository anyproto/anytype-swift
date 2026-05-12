import Foundation
import SwiftProtobuf
import AnytypeCore

public struct RelationPlaceholder: Sendable {
    public let type: PlaceholderType
    public let value: Google_Protobuf_Value?

    init?(_ protobufValue: Google_Protobuf_Value) {
        guard case .structValue(let structValue) = protobufValue.kind else { return nil }
        guard let typeValue = structValue.fields["type"]?.safeIntValue else { return nil }
        self.type = PlaceholderType(rawValue: typeValue)
        self.value = structValue.fields["value"]
    }
}
