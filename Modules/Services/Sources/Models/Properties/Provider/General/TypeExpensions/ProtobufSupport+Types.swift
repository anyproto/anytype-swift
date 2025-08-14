import Foundation
import SwiftProtobuf
import AnytypeCore

extension String: ProtobufSupport {
    public init?(_ value: Google_Protobuf_Value) {
        self = value.stringValue
    }
}

extension Int: ProtobufSupport {
     public init?(_ value: Google_Protobuf_Value) {
        guard let intValue = value.safeIntValue else { return nil }
        self = intValue
    }
}

extension Double: ProtobufSupport {
     public init?(_ value: Google_Protobuf_Value) {
        guard let intValue = value.safeDoubleValue else { return nil }
        self = intValue
    }
}

extension Bool: ProtobufSupport {
    public init?(_ value: Google_Protobuf_Value) {
        self = value.boolValue
    }
}

extension AnytypeURL: ProtobufSupport {
    public init?(_ value: Google_Protobuf_Value) {
        let stringValue = value.stringValue
        guard stringValue.isNotEmpty, let url = AnytypeURL(string: stringValue) else { return nil }
        self = url
    }
}

extension Date: ProtobufSupport {
    public init?(_ value: Google_Protobuf_Value) {
        guard let timeInterval = value.safeDoubleValue, !timeInterval.isZero else { return nil }
        self = Date(timeIntervalSince1970: timeInterval)
    }
}

extension Emoji: ProtobufSupport {
    public init?(_ value: Google_Protobuf_Value) {
        guard let emoji = Emoji(value.stringValue) else { return nil }
        self = emoji
    }
}
