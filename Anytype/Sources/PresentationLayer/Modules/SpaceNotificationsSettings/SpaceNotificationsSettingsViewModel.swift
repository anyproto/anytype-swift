import Foundation
import Services
import AnytypeCore

struct SpaceNotificationsSettingsModuleData: Identifiable, Hashable {
    let spaceId: String
    var id: Int { hashValue }
}

struct CustomChatNotification: Identifiable {
    let chatId: String
    let icon: Icon
    let title: String
    let mode: SpaceNotificationsSettingsMode
    var id: String { chatId }
}

@MainActor
@Observable
final class SpaceNotificationsSettingsViewModel {

    // MARK: - Dependencies

    @ObservationIgnored
    private let data: SpaceNotificationsSettingsModuleData

    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    @ObservationIgnored @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    // MARK: - State

    var mode = SpaceNotificationsSettingsMode.allActiviy
    var dismiss = false
    var status: PushNotificationsSettingsStatus?
    var chatsWithCustomNotifications: [CustomChatNotification] = []

    @ObservationIgnored
    private var spaceView: SpaceView?

    // MARK: - Lifecycle

    init(data: SpaceNotificationsSettingsModuleData) {
        self.data = data
    }

    func startSubscriptions() async {
        async let participantSpacesTask: () = subscribeToParticipantSpacesStorage()
        async let systemSettingsTask: () = subscribeToSystemSettingsChanges()
        async let chatDetailsTask: () = subscribeToChatDetails()

        _ = await (participantSpacesTask, systemSettingsTask, chatDetailsTask)
    }

    // MARK: - Actions

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

    func onRemoveCustomSetting(chatId: String) async throws {
        try await workspaceService.pushNotificationResetIds(spaceId: data.spaceId, chatIds: [chatId])
    }

    func disabledStatus() -> Bool {
        guard let status else {
            return true
        }
        return !status.isAuthorized
    }

    // MARK: - Subscriptions

    private func subscribeToParticipantSpacesStorage() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: data.spaceId).values {
            let spaceView = participantSpaceView.spaceView
            self.mode = spaceView.pushNotificationMode.asNotificationsSettingsMode
            self.spaceView = spaceView
            await updateChatsWithCustomNotifications()
        }
    }

    private func subscribeToSystemSettingsChanges() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.status = status.asPushNotificationsSettingsStatus
        }
    }

    private func subscribeToChatDetails() async {
        for await _ in await chatDetailsStorage.allChatsSequence {
            await updateChatsWithCustomNotifications()
        }
    }

    // MARK: - Private

    private func updateChatsWithCustomNotifications() async {
        guard let spaceView else {
            chatsWithCustomNotifications = []
            return
        }

        var chats: [CustomChatNotification] = []

        for chatId in spaceView.forceAllIds {
            if let details = await chatDetailsStorage.chat(id: chatId) {
                chats.append(CustomChatNotification(chatId: chatId, icon: details.objectIconImage, title: details.pluralTitle, mode: .allActiviy))
            }
        }
        for chatId in spaceView.forceMuteIds {
            if let details = await chatDetailsStorage.chat(id: chatId) {
                chats.append(CustomChatNotification(chatId: chatId, icon: details.objectIconImage, title: details.pluralTitle, mode: .disabled))
            }
        }
        for chatId in spaceView.forceMentionIds {
            if let details = await chatDetailsStorage.chat(id: chatId) {
                chats.append(CustomChatNotification(chatId: chatId, icon: details.objectIconImage, title: details.pluralTitle, mode: .mentions))
            }
        }

        chatsWithCustomNotifications = chats.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}
