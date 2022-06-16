//
//  EventsLogViewModel.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore
import Combine
import Foundation
import os

final class EventsLogViewModel: ObservableObject {
    let events: [LogEventStorage.Event] = LogEventStorage.storage.events

    private var fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/logs.txt")

    func flush() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func exportDataFileURL() -> URL {
        let data = LoggerEventsMarkupHelper.exportableData(from: events) ?? Data()
        try? data.write(to: fileURL)

        return fileURL
    }
}

extension LogEventStorage.Event: Identifiable {
    public var id: String {
        return date.description + message
    }
}
