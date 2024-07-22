import Services
import SwiftUI
import Foundation
import AnytypeCore

@MainActor
protocol VersionHistoryDataBuilderProtocol {
    func buildData(for versions: [VersionHistory], participants: [String: Participant]) -> [VersionHistoryItem]
}

@MainActor
final class VersionHistoryDataBuilder: VersionHistoryDataBuilderProtocol {
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    nonisolated init() { }
    
    func buildData(for versions: [VersionHistory], participants: [String: Participant]) -> [VersionHistoryItem] {
        versions.compactMap { version in
            guard let participant = participants[version.authorID] else { return nil }
            return VersionHistoryItem(
                id: version.id,
                time: buildDateString(for: version),
                author: participant.localName,
                icon: participant.icon
            )
        }
    }
    
    private func buildDateString(for version: VersionHistory) -> String {
        let timeInterval = Double(version.time)
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateFormatter.string(from: date)
    }
}

extension Container {
    var versionHistoryDataBuilder: Factory<any VersionHistoryDataBuilderProtocol> {
        self { VersionHistoryDataBuilder() }.shared
    }
}
