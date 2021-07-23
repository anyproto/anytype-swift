import Foundation
import os

struct LoggerCategory: ExpressibleByStringLiteral {
    let category: String

    init(category: String) {
        self.category = category
    }
    
    init(stringLiteral value: String) {
        self = .init(category: value)
    }
}

extension LoggerCategory {
    static let `default`: Self = "default"
}


extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "AnyTypeLogger"
    
    static func create(_ category: LoggerCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.category)
    }
    
    static func `default`() -> Logger {
        create(.default)
    }
}
