import Foundation
import Services
@preconcurrency import Combine
import ProtobufMessages
import AnytypeCore

@MainActor
final class GalleryNotificationViewModel: ObservableObject {
    
    private var notification: NotificationGalleryImport
    
    @Injected(\.notificationsSubscriptionService)
    private var notificationSubscriptionService: any NotificationsSubscriptionServiceProtocol
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.notificationsService)
    private var notificationsService: any NotificationsServiceProtocol
    
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
        try await activeSpaceManager.setActiveSpace(spaceId: notification.galleryImport.spaceID)
        try await notificationsService.reply(ids: [notification.common.id], actionType: .close)
        dismiss.toggle()
    }
    
    // MARK: - Private
    
    private func startHandle() async {
        subscription = await notificationSubscriptionService.handleGalleryImportUpdate(notificationID: notification.common.id) { [weak self] notification in
            await self?.updateView(notification: notification)
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
