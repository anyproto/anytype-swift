import Services
import SwiftUI

@MainActor
final class VersionHistoryViewModel: ObservableObject {
    
    @Published var groups = [VersionHistoryDataGroup]()
    @Published var expandedGroups: Set<String> = []
    
    private let objectId: String
    private let spaceId: String
    private var rawVersions = [VersionHistory]()
    private var participantsDict = [String: Participant]()
    
    private var firstOpen = true
    
    @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    @Injected(\.versionHistoryDataBuilder)
    private var versionHistoryDataBuilder: any VersionHistoryDataBuilderProtocol
    
    private lazy var participantsSubscription: ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    
    init(data: VersionHistoryData) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
    }
    
    func startParticipantsSubscription() async {
        for await participants in participantsSubscription.participantsPublisher.values {
            participantsDict = [:]
            participants.forEach { participant in
                participantsDict[participant.id] = participant
            }
            updateView()
        }
    }
    
    func getVersions() async {
        do {
            rawVersions = try await historyVersionsService.getVersions(objectId: objectId)
            updateView()
        } catch {
            groups = []
        }
    }
    
    func onGroupTap(_ group: VersionHistoryDataGroup) {
        if expandedGroups.contains(group.title) {
            expandedGroups.remove(group.title)
        } else {
            expandedGroups.insert(group.title)
        }
    }
    
    private func updateView() {
        guard rawVersions.isNotEmpty, !participantsDict.keys.isEmpty else { return }
        
        updateExpandedGroupsOnFirstOpen()
        groups = versionHistoryDataBuilder.buildData(for: rawVersions, participants: participantsDict)
    }
    
    private func updateExpandedGroupsOnFirstOpen() {
        guard firstOpen else { return }
        
        if let firstGroupKey = versionHistoryDataBuilder.buildFirstGroupKey(
            for: rawVersions,
            participants: participantsDict
        ) {
            expandedGroups.insert(firstGroupKey)
        }
        
        firstOpen = false
    }
}