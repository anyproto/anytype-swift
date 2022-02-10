import Foundation
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import AnytypeCore

struct GoogleProtobufStructuresConverter {
    static func structure(_ from: [String: Any]) -> Google_Protobuf_Struct {
        anytypeAssertionFailure("No conversion for categories", domain: .protobufConverter)
        return [:]
    }
}
