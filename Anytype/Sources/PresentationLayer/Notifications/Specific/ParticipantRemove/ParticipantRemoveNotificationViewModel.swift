import Foundation

@MainActor
final class ParticipantRemoveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRemove
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private let onDelete: (_ spaceId: String) async -> Void
    
    @Published var message: String = ""
    @Published var dismiss = false
    
    init(notification: NotificationParticipantRemove, onDelete: @escaping (_ spaceId: String) async -> Void) {
        self.notification = notification
        self.onDelete = onDelete
        message = Loc.ParticipantRemoveNotification.text
    }
    
    func onTapExport() {
        // TODO: Implement
        dismiss.toggle()
    }
    
    func onTapDelete() async {
        await onDelete(notification.remove.spaceID)
        dismiss.toggle()
    }
}
