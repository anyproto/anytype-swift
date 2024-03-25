import Foundation

@MainActor
final class ParticipantRemoveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRemove
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    @Published var message: String = ""
    @Published var dismiss = false
    
    init(notification: NotificationParticipantRemove) {
        self.notification = notification
        message = Loc.ParticipantRemoveNotification.text
    }
    
    func onTapExport() {
        // TODO: Implement
        dismiss.toggle()
    }
    
    func onTapDelete() {
        // TODO: Implement
        dismiss.toggle()
    }
}
