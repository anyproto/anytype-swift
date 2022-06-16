//
//  LoggerEventsMarkupHelper.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore
import Foundation
import os

final class LoggerEventsMarkupHelper {
    static func exportableData(from events: [LogEventStorage.Event]) -> Data? {
        var logString = String()

        events.forEach { event in
            logString.append(contentsOf: event.date.description + " " + event.category + " " + event.osLogType.emojiRepresentation)
            logString.append(contentsOf: "\n")
            logString.append(contentsOf: event.message)
            logString.append(contentsOf: "\n\n")
        }

        return logString.data(using: .utf8)
    }
}

private extension OSLogType {
    var emojiRepresentation: String {
        switch self {
        case .error: return "🛑"
        case .fault: return "❌"
        case .info: return "⚠️"
        default: return "ℹ️"
        }
    }
}
