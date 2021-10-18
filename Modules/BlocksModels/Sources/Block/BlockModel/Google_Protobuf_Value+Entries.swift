import SwiftProtobuf
import AnytypeCore

extension Google_Protobuf_Value {
    
    public var unwrapedListValue: Google_Protobuf_Value {
        // Relation fields (for example, iconEmoji/iconImage etc.) can come as single value or as list of values.
        // For current moment if we receive list of values we handle only first value of the list.
        if case let .listValue(listValue) = self.kind, let firstValue = listValue.values.first {
            return firstValue
        }
        return self
    }
    
}
