import Services
import SwiftUI
import Foundation
import AnytypeCore
import OrderedCollections

@MainActor
protocol VersionHistoryDataBuilderProtocol {
    func buildData(for versions: [VersionHistory], participants: [String: Participant]) -> [VersionHistoryDataGroup]
}

@MainActor
final class VersionHistoryDataBuilder: VersionHistoryDataBuilderProtocol {
    
    private let dateFormatter = VersionHistoryDateFormatter()
    private let timeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    nonisolated init() { }
    
    func buildData(for versions: [VersionHistory], participants: [String: Participant]) -> [VersionHistoryDataGroup] {
        
        var versionsByDay: OrderedDictionary<String, [VersionHistory]> = [:]
        
        for version in versions {
            guard participants[version.authorID].isNotNil else { continue }
            let versionDateString = buildDateString(for: version)
            versionsByDay[versionDateString, default: []].append(version)
        }
        
        var versionsByDayByAuthor: OrderedDictionary<String, [[VersionHistory]]> = [:]
        
        for (key, versions) in versionsByDay {
            var versionsByAuthor = [VersionHistory]()
            var versionsByAuthors = [[VersionHistory]]()
            
            for version in versions {
                let lastParticipantId = versionsByAuthor.last?.authorID
                if let lastParticipantId, lastParticipantId == version.authorID {
                    versionsByAuthor.append(version)
                } else {
                    if versionsByAuthor.isNotEmpty {
                        versionsByAuthors.append(versionsByAuthor)
                    }
                    versionsByAuthor = [version]
                }
                
                if version == versions.last {
                    versionsByAuthors.append(versionsByAuthor)
                }
            }
            
            versionsByDayByAuthor[key] = versionsByAuthors
        }
        
        var groups = [VersionHistoryDataGroup]()
        
        for (key, values) in versionsByDayByAuthor {
            var versionsByAuthors = [[VersionHistoryItem]]()
            var groupIcons: OrderedSet<ObjectIcon> = []
            
            for versions in values {
                let versionsByAuthor = versions.compactMap { version -> VersionHistoryItem? in
                    guard let participant = participants[version.authorID] else { return nil }
                    if let icon = participant.icon {
                        groupIcons.append(icon)
                    }
                    return buildVersionHistoryItem(for: version, participant: participant)
                }
                versionsByAuthors.append(versionsByAuthor)
            }
            
            groups.append(
                VersionHistoryDataGroup(
                    title: key,
                    icons: groupIcons.elements,
                    versions: versionsByAuthors
                )
            )
        }
        
        return groups
    }
    
    private func buildVersionHistoryGroup(for version: VersionHistory, participant: Participant) -> VersionHistoryItem {
        VersionHistoryItem(
            id: version.id,
            time: buildTimeString(for: version),
            author: participant.localName,
            icon: participant.icon
        )
    }
    
    private func buildVersionHistoryItem(for version: VersionHistory, participant: Participant) -> VersionHistoryItem {
        VersionHistoryItem(
            id: version.id,
            time: buildTimeString(for: version),
            author: participant.localName,
            icon: participant.icon
        )
    }
    
    private func buildDate(for version: VersionHistory) -> Date {
        let timeInterval = Double(version.time)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    private func buildDateString(for version: VersionHistory) -> String {
        let date = buildDate(for: version)
        return dateFormatter.localizedString(for: date)
    }
    
    private func buildTimeString(for version: VersionHistory) -> String {
        let date = buildDate(for: version)
        return timeFormatter.string(from: date)
    }
}

extension Container {
    var versionHistoryDataBuilder: Factory<any VersionHistoryDataBuilderProtocol> {
        self { VersionHistoryDataBuilder() }.shared
    }
}
