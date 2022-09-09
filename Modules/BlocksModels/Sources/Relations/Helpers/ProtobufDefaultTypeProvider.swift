import Foundation

public protocol ProtobufDefaultTypeProvider {
    static func protobufDefaultType() -> Self
}

extension String: ProtobufDefaultTypeProvider {
    public static func protobufDefaultType() -> Self {
        return ""
    }
}

extension Bool: ProtobufDefaultTypeProvider {
    public static func protobufDefaultType() -> Self {
        return false
    }
}
