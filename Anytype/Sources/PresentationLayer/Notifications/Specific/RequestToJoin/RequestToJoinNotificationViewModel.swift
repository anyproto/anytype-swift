import Foundation
import Services

@MainActor
final class RequestToJoinNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToJoin
    
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.notificationsService)
    private var notificationsService: any NotificationsServiceProtocol
    
    private let onViewRequest: (_ notification: NotificationRequestToJoin) async -> Void
    
    @Published var message: String = ""
    @Published var toast: ToastBarData?
    @Published var dismiss = false
    
    init(
        notification: NotificationRequestToJoin,
        onViewRequest: @escaping (_ notification: NotificationRequestToJoin) async -> Void
    ) {
        self.notification = notification
        self.onViewRequest = onViewRequest
        message = Loc.RequestToJoinNotification.text(
            notification.requestToJoin.identityName.withPlaceholder.trimmingCharacters(in: .whitespaces),
            notification.requestToJoin.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
        )
    }
    
    func onTapGoToSpace() async throws {
        try await activeSpaceManager.setActiveSpace(spaceId: notification.requestToJoin.spaceID)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
    
    func onTapViewRequest() async throws {
        await onViewRequest(notification)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
}
