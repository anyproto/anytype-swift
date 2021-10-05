//
//  MiddlewareLogger.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import os

public final class LogEventStorage {
    public struct Event {
        public let category: String
        public let date: Date
        public let message: String
        public let osLogType: OSLogType
    }

    public private(set) var events = [Event]()

    public static let storage = LogEventStorage()

    func flush() {
        events.removeAll()
    }

    func recordEvent(category: String, message: String, osLogType: OSLogType) {
        let event = Event(category: category, date: Date(), message: message, osLogType: osLogType)
        events.append(event)
    }
}
