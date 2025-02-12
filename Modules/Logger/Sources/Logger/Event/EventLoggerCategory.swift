import Foundation

public struct EventLoggerCategory: ExpressibleByStringLiteral, Sendable {
    public let category: String

    public init(category: String) {
        self.category = category
    }

    public init(stringLiteral value: String) {
        self = .init(category: value)
    }
}

public extension EventLoggerCategory {
    static let `default`: Self = "default"
}

public extension EventLogger {
   convenience init(category: EventLoggerCategory) {
       self.init(category: category.category)
    }
}
