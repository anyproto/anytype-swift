public struct ObjectTypeUniqueKey: Equatable, Hashable, Codable {
    public let value: String
}

public extension ObjectTypeUniqueKey {
    static let empty = ObjectTypeUniqueKey(value: "")
}
