import Foundation
import SwiftProtobuf

public protocol PropertyValueProvider {
    
    var values: [String: Google_Protobuf_Value] { get }
    
}

extension PropertyValueProvider {
    
    func value<T>(for key: String) -> T? where T: ProtobufSupport {
        guard let value = values[key]?.unwrapedListValue else { return nil }
        return T(value)
    }

    func value<T>(for key: String) -> T where T: ProtobufSupport, T: ProtobufDefaultTypeProvider {
        guard let value = values[key]?.unwrapedListValue else { return T.protobufDefaultType() }
        return T(value) ?? T.protobufDefaultType()
    }

    func value<T: ProtobufSupport>(for key: String) -> [T] {
        guard let values = values[key]?.listValue.values else { return [] }
        return values.compactMap { T($0) }
    }
}

public extension PropertyValueProvider {
    
    func stringValue(for key: String) -> String {
        value(for: key)
    }
    
    func stringArrayValue(for key: String) -> [String] {
        value(for: key)
    }

    func boolValue(for key: String) -> Bool {
        value(for: key)
    }
    
    func dateValue(for key: String) -> Date? {
        value(for: key)
    }
    
    func doubleValue(for key: String) -> Double? {
        value(for: key)
    }
    
    func intValue(for key: String) -> Int? {
        value(for: key)
    }
}
