import Foundation
import Services

@MainActor
final class RequestToJoinNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToJoin
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var message: String = ""
    @Published var icon: Icon?
    @Published var toast: ToastBarData = .empty
    @Published var dismiss = false
    
    init(notification: NotificationRequestToJoin) {
        self.notification = notification
        let spaceView = workspaceStorage.spaceView(spaceId: notification.requestToJoin.spaceID)
        icon = spaceView?.iconImage
        message = Loc.RequestToJoinNotification.text(notification.requestToJoin.identityName, spaceView?.name ?? "")
    }
    
    func onTapGoToSpace() async throws {
        try await activeWorkpaceStorage.setActiveSpace(spaceId: notification.requestToJoin.spaceID)
        dismiss.toggle()
    }
    
    func onTapViewRequest() {
        // TODO: Implement
    }
}
