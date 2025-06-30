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
    
    @Published var mode = SpaceNotificationsSettingsMode.allActiviy
    @Published var dismiss = false
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self.data = data
    }
    
    func startParticipantSpacesStorageTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: data.spaceId).values {
            self.mode = participantSpaceView.spaceView.pushNotificationMode.asNotificationsSettingsMode
        }
    }
    
    func onModeChange(_ mode: SpaceNotificationsSettingsMode) async throws {
        let pushNotificationsMode = mode.asPushNotificationsMode
        try await workspaceService.pushNotificationSetSpaceMode(
            spaceId: data.spaceId,
            mode: pushNotificationsMode
        )
        AnytypeAnalytics.instance().logChangeMessageNotificationState(
            type: pushNotificationsMode.analyticsValue,
            route: .spaceSettings
        )
        dismiss.toggle()
    }
}
