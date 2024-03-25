import Foundation
import Services

@MainActor
final class RequestToLeaveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToLeave
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    @Published var message: String = ""
    @Published var toast: ToastBarData = .empty
    @Published var dismiss = false
    
    init(notification: NotificationRequestToLeave) {
        self.notification = notification
        message = Loc.RequestToLeaveNotification.text(notification.requestToLeave.identityName, notification.requestToLeave.spaceName)
    }
    
    func onTapApprove() async throws {
        try await workspaceService.participantRemove(spaceId: notification.requestToLeave.spaceID, identity: notification.requestToLeave.identity)
        toast = ToastBarData(text: Loc.SpaceShare.Approve.toast(notification.requestToLeave.identityName), showSnackBar: true)
        dismiss.toggle()
    }
}
