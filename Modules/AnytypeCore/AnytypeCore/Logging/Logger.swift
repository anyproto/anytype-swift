import Foundation
import os

public struct LoggerCategory: ExpressibleByStringLiteral {
    public let category: String

    public init(category: String) {
        self.category = category
    }
    
    public init(stringLiteral value: String) {
        self = .init(category: value)
    }
}

public extension LoggerCategory {
    static let `default`: Self = "default"
}
