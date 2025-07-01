import Foundation

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
