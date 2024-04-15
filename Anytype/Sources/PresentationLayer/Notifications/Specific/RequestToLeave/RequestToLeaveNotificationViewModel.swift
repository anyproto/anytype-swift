import Foundation
import Services

@MainActor
final class RequestToLeaveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToLeave
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.notificationsService)
    private var notificationsService: NotificationsServiceProtocol
    
    @Published var message: String = ""
    @Published var toast: ToastBarData = .empty
    @Published var dismiss = false
    
    init(notification: NotificationRequestToLeave) {
        self.notification = notification
        message = Loc.RequestToLeaveNotification.text(notification.requestToLeave.identityName.withPlaceholder, notification.requestToLeave.spaceName.withPlaceholder)
    }
    
    func onTapApprove() async throws {
        AnytypeAnalytics.instance().logApproveLeaveRequest()
        try await workspaceService.leaveApprove(spaceId: notification.requestToLeave.spaceID, identity: notification.requestToLeave.identity)
        toast = ToastBarData(text: Loc.SpaceShare.Approve.toast(notification.requestToLeave.identityName), showSnackBar: true)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
}
