import Foundation
import Services
import Combine
import ProtobufMessages
import AnytypeCore

@MainActor
final class GalleryNotificationViewModel: ObservableObject {
    
    private let notification: Services.Notification
    private let notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    private var subscription: AnyCancellable?
    private let workspaceStorage: WorkspacesStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    private var galleryImportNotification: NotificationGalleryImport?
    
    @Published var title: String = ""
    
    init(
        notification: Services.Notification,
        notificationSubscriptionService: NotificationsSubscriptionServiceProtocol,
        workspaceStorage: WorkspacesStorageProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.notification = notification
        self.notificationSubscriptionService = notificationSubscriptionService
        self.workspaceStorage = workspaceStorage
        self.activeWorkspaceStorage = activeWorkspaceStorage
        Task {
            await updateView(notification: notification)
            await startHandle()
        }
    }
    
    
    func startHandle() async {
        subscription = await notificationSubscriptionService.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func onTapSpace() {
        guard let galleryImportNotification else {
            anytypeAssertionFailure("Try to open space without notification")
            return
        }
        Task {
            try await activeWorkspaceStorage.setActiveSpace(spaceId: galleryImportNotification.spaceID)
        }
    }
    
    private func handle(events: [NotificationEvent]) async {
        for event in events {
            switch event {
            case .update(let data):
                guard data.id == notification.id else { continue }
                await updateView(notification: notification)
            case .send:
                continue
            }
        }
    }
    
    private func updateView(notification: Services.Notification) async {
        switch notification.payload {
        case .galleryImport(let galleryImport):
            galleryImportNotification = galleryImport
            if galleryImport.errorCode != .null {
                title = Loc.Gallery.Notification.error(galleryImport.name)
            } else {
                let spaceView = await workspaceStorage.spaceView(spaceId: galleryImport.spaceID)
                title = Loc.Gallery.Notification.success(spaceView?.name ?? "")
            }
        default:
            break
        }
    }
}
