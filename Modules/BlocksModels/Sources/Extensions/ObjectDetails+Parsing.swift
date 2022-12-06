import SwiftProtobuf
import AnytypeCore

public extension Array where Element == Google_Protobuf_Struct {
    
    var asDetais: [ObjectDetails] {
        compactMap { ObjectDetails(protobufStruct: $0) }
    }
}
