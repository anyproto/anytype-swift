//
//  EventsLogView.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI
import AnytypeCore
import os

struct EventsLogView: View {
    @StateObject var viewModel: EventsLogViewModel
    @State private var isShareLogsPresented = false
    var body: some View {
        NavigationView {
            List(viewModel.events) { event in
                EventRow(event: event)
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        isShareLogsPresented.toggle()
                    }) { Image(systemName: "square.and.arrow.up")}
            )
            .sheet(
                isPresented: $isShareLogsPresented,
                onDismiss: { viewModel.flush() }
            ) {
                ActivityViewController(activityItems: [viewModel.exportDataFileURL()])
            }
        }
    }
}

private struct EventRow: View {
    let event: LogEventStorage.Event

    var body: some View {
        VStack {
            HStack {
                AnytypeText(event.category, style: .caption1Regular, color: .primary)
                AnytypeText(event.date.description, style: .caption2Regular, color: .primary)

            }
            Text(event.message)
                .background(event.osLogType.backgroundColor)
                .multilineTextAlignment(.leading)
        }
    }
}

private extension OSLogType {
    var backgroundColor: Color {
        switch self {
        case .error: return .red.opacity(0.2)
        case .fault: return .red.opacity(0.4)
        case .info: return .yellow.opacity(0.2)
        default: return .white
        }
    }
}
