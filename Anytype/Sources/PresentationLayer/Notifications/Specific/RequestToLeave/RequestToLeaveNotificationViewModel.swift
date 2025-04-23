import Foundation
import Services

@MainActor
final class RequestToLeaveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToLeave
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.notificationsService)
    private var notificationsService: any NotificationsServiceProtocol
    
    @Published var message: String = ""
    @Published var toast: ToastBarData?
    @Published var dismiss = false
    
    init(notification: NotificationRequestToLeave) {
        self.notification = notification
        message = Loc.RequestToLeaveNotification.text(
            notification.requestToLeave.identityName.withPlaceholder.trimmingCharacters(in: .whitespaces),
            notification.requestToLeave.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
        )
    }
    
    func onTapApprove() async throws {
        AnytypeAnalytics.instance().logApproveLeaveRequest()
        try await workspaceService.leaveApprove(spaceId: notification.requestToLeave.spaceID, identity: notification.requestToLeave.identity)
        toast = ToastBarData(Loc.SpaceShare.Approve.toast(notification.requestToLeave.identityName))
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
}
