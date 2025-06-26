import Foundation
import Services
import AnytypeCore

struct SpaceNotificationsSettingsModuleData: Identifiable, Hashable {
    let spaceId: String
    var id: Int { hashValue }
}

@MainActor
final class SpaceNotificationsSettingsViewModel: ObservableObject {
    
    private let data: SpaceNotificationsSettingsModuleData
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    @Published var state = SpaceNotificationsSettingsState.allActiviy
    @Published var dismiss = false
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self.data = data
    }
    
    func startParticipantSpacesStorageTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: data.spaceId).values {
            self.state = participantSpaceView.spaceView.pushNotificationMode.asNotificationsSettingsState
        }
    }
    
    func onStateChange(_ state: SpaceNotificationsSettingsState) async throws {
        try await workspaceService.pushNotificationSetSpaceMode(
            spaceId: data.spaceId,
            mode: state.asPushNotificationsMode
        )
        dismiss.toggle()
    }
}
