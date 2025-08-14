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
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    
    @Published var mode = SpaceNotificationsSettingsMode.allActiviy
    @Published var dismiss = false
    @Published var status: PushNotificationsSettingsStatus?
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self.data = data
    }
    
    func startSubscriptions() async {
        async let participantSpacesTask: () = subscribeToParticipantSpacesStorage()
        async let systemSettingsTask: () = subscribeToSystemSettingsChanges()
        
        _ = await (participantSpacesTask, systemSettingsTask)
    }
    
    private func subscribeToParticipantSpacesStorage() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: data.spaceId).values {
            self.mode = participantSpaceView.spaceView.pushNotificationMode.asNotificationsSettingsMode
        }
    }
    
    
    private func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.status = status.asPushNotificationsSettingsStatus
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
    
    func disabledStatus() -> Bool {
        guard let status else {
            return true
        }
        return !status.isAuthorized
    }
}
