import SwiftProtobuf

struct HashableConverter {
    static func dictionary(_ from: Google_Protobuf_Struct) -> [String: AnyHashable] {
        from.fields
    }
    static func structure(_ from: [String: Any]) -> Google_Protobuf_Struct {
        return [:]
    }
}
