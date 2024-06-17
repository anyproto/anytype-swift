import Foundation

public struct BlockRelation: Hashable, Sendable {
    public var key: String

    public init(key: String) {
        self.key = key
    }
}
