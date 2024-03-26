import Foundation
import Services

@MainActor
final class RequestToJoinNotificationViewModel: ObservableObject {
    
    private let notification: NotificationRequestToJoin
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkpaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var message: String = ""
    @Published var toast: ToastBarData = .empty
    @Published var dismiss = false
    
    init(notification: NotificationRequestToJoin) {
        self.notification = notification
        message = Loc.RequestToJoinNotification.text(notification.requestToJoin.identityName.withPlaceholder, notification.requestToJoin.spaceName.withPlaceholder)
    }
    
    func onTapGoToSpace() async throws {
        try await activeWorkpaceStorage.setActiveSpace(spaceId: notification.requestToJoin.spaceID)
        dismiss.toggle()
    }
    
    func onTapViewRequest() {
        // TODO: Implement
    }
}
