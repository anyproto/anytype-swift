//
//  Logging.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os

// MARK: Example
//private extension Logging.Categories {
//    static let customCategory: Self = "yourDesiredValue"
//}

enum Logging {
    enum Subsystems {
        static let iOSApp = "org.anytype.anytype"
    }
    static let subsystem = Subsystems.iOSApp
    
    // NOTE: `OSLog.init(subsystem:category:)` is thread-safe AND cheap.
    // It will `findOrCreate` new logger, cause every logger is signleton.
    // For further information look at os_log documentation.
    static func createLogger(category: Categories) -> OSLog {
        .init(subsystem: subsystem, category: category.category)
    }
    private static func createLogger(category: String) -> OSLog {
        .init(subsystem: subsystem, category: category)
    }
}

extension Logging {
    struct Categories: ExpressibleByStringLiteral {
        var category: String = ""

        init(category: String) {
            self.category = category
        }
        
        init(stringLiteral value: String) {
            self = .init(category: value)
        }
    }
}

extension Logging.Categories {
    enum TODO {
        enum OS: String {
            case os14
        }
        case `default`(String)
        case remove(String)
        case improve(String)
        case refactor(String)
        case workaround(OS, String)
        var category: String {
            switch self {
            case let .default(value): return "TODO: \(value)"
            case let .remove(value): return "TODO: Remove \(value)"
            case let .improve(value): return "TODO: Improve \(value)"
            case let .refactor(value): return "TODO: Refactor \(value)"
            case let .workaround(os, value): return "TODO: Workaround for OS below \(os). Read it. \(value)"
            }
        }
    }
    
    static func todo(_ todo: TODO) -> Self {
        .init(category: todo.category)
    }
}
