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


public extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "AnyTypeLogger"
    
    static func create(_ category: LoggerCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.category)
    }
    
    static func `default`() -> os.Logger {
        create(.default)
    }
}
