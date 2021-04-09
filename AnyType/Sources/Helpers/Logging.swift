//
//  Logging.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import os
import OSLog

// MARK: Example
//private extension Logging.Categories {
//    static let customCategory: Self = "yourDesiredValue"
//}

enum Logging {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "AnyTypeLogger"
    
    static func createLogger(category: Categories) -> OSLog {
        self.createLogger(category: category.category)
    }
    private static func createLogger(category: String) -> OSLog {
        .init(subsystem: self.subsystem, category: category)
    }
    static func createOSLogger(category: Categories) -> Logger {
        self.createOSLogger(category: category.category)
    }
    private static func createOSLogger(category: String) -> Logger {
        .init(subsystem: self.subsystem, category: category)
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

extension Logger {
    static func create(_ category: Logging.Categories) -> Logger {
        Logging.createOSLogger(category: category)
    }
}
