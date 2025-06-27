import Foundation

public struct BlockProperty: Hashable, Sendable {
    public var key: String

    public init(key: String) {
        self.key = key
    }
}
