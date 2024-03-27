import Foundation
import Services
import Combine
import ProtobufMessages
import AnytypeCore

@MainActor
final class GalleryNotificationViewModel: ObservableObject {
    
    private var notification: NotificationGalleryImport
    @Injected(\.notificationsSubscriptionService)
    private var notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.notificationsService)
    private var notificationsService: NotificationsServiceProtocol
    
    private var subscription: AnyCancellable?
    
    @Published var title: String = ""
    @Published var dismiss = false
    
    init(
        notification: NotificationGalleryImport
    ) {
        self.notification = notification
        updateView(notification: notification)
        Task {
            await startHandle()
        }
    }
    
    func onTapSpace() async throws {
        try await activeWorkspaceStorage.setActiveSpace(spaceId: notification.galleryImport.spaceID)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
    
    // MARK: - Private
    
    private func startHandle() async {
        subscription = await notificationSubscriptionService.handleGalleryImportUpdate(notificationID: notification.common.id) { [weak self] notification in
            self?.updateView(notification: notification)
        }
    }
    
    private func handle(events: [NotificationEvent]) {
        for event in events {
            switch event {
            case .update(let data):
                guard data.id == notification.common.id else { continue }
                updateView(notification: notification)
            case .send:
                continue
            }
        }
    }
    
    private func updateView(notification: NotificationGalleryImport) {
        self.notification = notification
        if notification.galleryImport.errorCode != .null {
            title = Loc.Gallery.Notification.error(notification.galleryImport.name)
        } else {
            let spaceView = workspaceStorage.spaceView(spaceId: notification.galleryImport.spaceID)
            title = Loc.Gallery.Notification.success(spaceView?.title ?? "")
        }
    }
}
