public struct ObjectTypeUniqueKey: Equatable, Hashable, Codable, Sendable {
    public let value: String
}

public extension ObjectTypeUniqueKey {
    static let empty = ObjectTypeUniqueKey(value: "")
}

// temporary solution due to removing note and task from system types
public extension ObjectTypeUniqueKey {
    static let note = ObjectTypeUniqueKey(value: "ot-note")
    static let task = ObjectTypeUniqueKey(value: "ot-task")
}
