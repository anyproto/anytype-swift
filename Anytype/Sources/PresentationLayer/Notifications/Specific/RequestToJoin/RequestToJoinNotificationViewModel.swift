import Foundation
import Services

@MainActor
final class RequestToJoinNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToJoin
    private let sceneId: String
    
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.notificationsService)
    private var notificationsService: any NotificationsServiceProtocol
    
    private let onViewRequest: (_ notification: NotificationRequestToJoin) async -> Void
    
    @Published var message: String = ""
    @Published var toast: ToastBarData = .empty
    @Published var dismiss = false
    
    init(
        notification: NotificationRequestToJoin,
        sceneId: String,
        onViewRequest: @escaping (_ notification: NotificationRequestToJoin) async -> Void
    ) {
        self.notification = notification
        self.sceneId = sceneId
        self.onViewRequest = onViewRequest
        message = Loc.RequestToJoinNotification.text(
            notification.requestToJoin.identityName.withPlaceholder.trimmingCharacters(in: .whitespaces),
            notification.requestToJoin.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
        )
    }
    
    func onTapGoToSpace() async throws {
        try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: notification.requestToJoin.spaceID)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
    
    func onTapViewRequest() async throws {
        await onViewRequest(notification)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
}
