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
        var groups = [VersionHistoryDataGroup]()
        var currentDate: Date?
        var currentParticipant: Participant?
        var groupIcons: OrderedSet<ObjectIcon> = []
        var currentVersions = [VersionHistoryItem]()
        var allVersions = [[VersionHistoryItem]]()
        
        for version in versions {
            if let participant = participants[version.authorID] {
                
                // set participant for the first time
                if currentParticipant.isNil {
                    currentParticipant = participant
                    if let icon = currentParticipant?.icon {
                        groupIcons.append(icon)
                    }
                }
                
                let versionDate = buildDate(for: version)
                
                if currentDate.isNil {
                    currentDate = versionDate
                }
                
                if let currentDate, dateFormatter.isDate(versionDate, inSameDayAs: currentDate) {
                    if let currentParticipant, participant == currentParticipant {
                        currentVersions.append(buildVersionHistoryItem(for: version, participant: participant))
                    } else {
                        allVersions.append(currentVersions)
                        currentVersions = []
                        currentParticipant = participant
                        if let icon = currentParticipant?.icon {
                            groupIcons.append(icon)
                        }
                    }
                } else {
                    currentVersions.append(buildVersionHistoryItem(for: version, participant: participant))
                    allVersions.append(currentVersions)
                    groups.append(
                        VersionHistoryDataGroup(
                            title: buildDateString(for: version),
                            icons: groupIcons.elements,
                            versions: allVersions
                        )
                    )
                    currentDate = versionDate
                    groupIcons = []
                    currentVersions = []
                    allVersions = []
                }
            }
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
