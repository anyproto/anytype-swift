import Foundation
import Services
import Combine
import ProtobufMessages
import AnytypeCore

@MainActor
final class GalleryNotificationViewModel: ObservableObject {
    
    private var notification: NotificationGalleryImport
    private let notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    private var subscription: AnyCancellable?
    private let workspaceStorage: WorkspacesStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var title: String = ""
    
    init(
        notification: NotificationGalleryImport,
        notificationSubscriptionService: NotificationsSubscriptionServiceProtocol,
        workspaceStorage: WorkspacesStorageProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.notification = notification
        self.notificationSubscriptionService = notificationSubscriptionService
        self.workspaceStorage = workspaceStorage
        self.activeWorkspaceStorage = activeWorkspaceStorage
        updateView(notification: notification)
        Task {
            await startHandle()
        }
    }
    
    
    func startHandle() async {
        subscription = await notificationSubscriptionService.handleGalleryImportUpdate(notificationID: notification.common.id) { [weak self] notification in
            self?.updateView(notification: notification)
        }
    }
    
    func onTapSpace() {
        Task {
            try await activeWorkspaceStorage.setActiveSpace(spaceId: notification.galleryImport.spaceID)
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
            title = Loc.Gallery.Notification.success(spaceView?.name ?? "")
        }
    }
}
