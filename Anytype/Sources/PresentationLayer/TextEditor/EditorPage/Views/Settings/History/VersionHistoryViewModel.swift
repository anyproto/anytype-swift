import Services
import SwiftUI
import OrderedCollections

@MainActor
protocol VersionHistoryModuleOutput: AnyObject {
    func onVersionTap(title: String, icon: ObjectIcon?, versionId: String)
}

@MainActor
@Observable
final class VersionHistoryViewModel {

    var groups = [VersionHistoryDataGroup]()
    var expandedGroups: Set<String> = []
    var lastViewedVersionId = ""

    @ObservationIgnored
    private let objectId: String
    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private var rawVersions = OrderedSet<VersionHistory>()
    @ObservationIgnored
    private var participantsDict = [String: Participant]()
    @ObservationIgnored
    private weak var output: (any VersionHistoryModuleOutput)?

    @ObservationIgnored
    private var firstOpen = true

    @ObservationIgnored @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    @ObservationIgnored @Injected(\.versionHistoryDataBuilder)
    private var versionHistoryDataBuilder: any VersionHistoryDataBuilderProtocol

    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    
    init(data: VersionHistoryData, output: (any VersionHistoryModuleOutput)?) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenHistory()
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
            let newVersions = try await historyVersionsService.getVersions(objectId: objectId, lastVersionId: lastViewedVersionId)
            rawVersions.append(contentsOf: newVersions)
            updateView()
        } catch {
            groups = []
        }
    }
    
    func onAppearLastGroup(_ group: VersionHistoryDataGroup) {
        guard groups.last == group else { return }
        guard lastViewedVersionId != rawVersions.last?.id else { return }
        lastViewedVersionId = rawVersions.last?.id ?? ""
    }
    
    func onGroupTap(_ group: VersionHistoryDataGroup) {
        if expandedGroups.contains(group.title) {
            expandedGroups.remove(group.title)
        } else {
            expandedGroups.insert(group.title)
        }
    }
    
    func onVersionTap(_ version: VersionHistoryItem) {
        output?.onVersionTap(title: version.dateTime, icon: version.icon, versionId: version.id)
    }
    
    private func updateView() {
        guard !rawVersions.isEmpty, !participantsDict.keys.isEmpty else { return }
        
        updateExpandedGroupsOnFirstOpen()
        groups = versionHistoryDataBuilder.buildData(for: rawVersions.elements, participants: participantsDict)
    }
    
    private func updateExpandedGroupsOnFirstOpen() {
        guard firstOpen else { return }
        
        if let firstGroupKey = versionHistoryDataBuilder.buildFirstGroupKey(
            for: rawVersions.elements,
            participants: participantsDict
        ) {
            expandedGroups.insert(firstGroupKey)
        }
        
        firstOpen = false
    }
}
