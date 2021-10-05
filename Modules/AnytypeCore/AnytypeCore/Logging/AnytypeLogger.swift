//
//  AnytypeLogger.swift
//  AnytypeCore
//
//  Created by Dmitry Bilienko on 04.10.2021.
//

import Foundation
import os

public final class AnytypeLogger {
    private let subsystem = Bundle.main.bundleIdentifier ?? "AnytypeLogger"
    private let category: String

    public init(category: String) {
        self.category = category
    }

    public func log(
        level: OSLogType,
        message: String
    ) {
        Logger(subsystem: subsystem, category: category)
            .log(level: level, "\(message)")
        LogEventStorage.storage.recordEvent(category: category, message: message, osLogType: level)
    }
}

public extension AnytypeLogger {
    static func create(_ category: LoggerCategory) -> AnytypeLogger {
        AnytypeLogger(category: category.category)
    }

    static func `default`() -> AnytypeLogger {
        create(.default)
    }
}

public extension AnytypeLogger {
    func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    func error(_ message: String) {
        log(level: .error, message: message)
    }

    func debugPrivate(_ message: String, arg: String) {
        Logger(subsystem: subsystem, category: category)
            .debug("\(message) \(arg, privacy: .private)")
    }
}
