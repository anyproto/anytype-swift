import Foundation
import Services

@MainActor
@Observable
final class RequestToJoinNotificationViewModel {

    private let notification: NotificationRequestToJoin

    @ObservationIgnored
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @ObservationIgnored
    @Injected(\.notificationsService)
    private var notificationsService: any NotificationsServiceProtocol

    private let onViewRequest: (_ notification: NotificationRequestToJoin) async -> Void

    var message: String = ""
    var toast: ToastBarData?
    var dismiss = false
    
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
