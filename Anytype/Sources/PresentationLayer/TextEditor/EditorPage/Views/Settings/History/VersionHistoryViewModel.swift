import Services
import SwiftUI

struct VersionHistoryData: Identifiable {
    let id: String
}

@MainActor
final class VersionHistoryViewModel: ObservableObject {
    
    @Published var versions = [VersionHistoryItem]()
    
    private let objectId: String
    private var rawVersions = [VersionHistory]()
    private var participantsDict = [String: Participant]()
    
    @Injected(\.historyVersionsService)
    private var historyVersionsService: any HistoryVersionsServiceProtocol
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: any ActiveSpaceParticipantStorageProtocol
    @Injected(\.versionHistoryDataBuilder)
    private var versionHistoryDataBuilder: any VersionHistoryDataBuilderProtocol
    
    init(data: VersionHistoryData) {
        self.objectId = data.id
    }
    
    func startParticipantsTask() async {
        for await participants in activeSpaceParticipantStorage.participantsPublisher.values {
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
            versions = []
        }
    }
    
    func updateView() {
        guard rawVersions.isNotEmpty, !participantsDict.keys.isEmpty else { return }
        versions = versionHistoryDataBuilder.buildData(for: rawVersions, participants: participantsDict)
    }
}
