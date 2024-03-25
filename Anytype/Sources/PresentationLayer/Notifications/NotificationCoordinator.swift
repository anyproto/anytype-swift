import Foundation
import Services
import Combine
import AnytypeCore
import SwiftEntryKit
import SwiftUI

@MainActor
final class NotificationCoordinatorViewModel: ObservableObject {
    
    @Injected(\.notificationsSubscriptionService)
    private var notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    private var subscription: AnyCancellable?
    
    @Published var spaceIdForDeleteAlert: StringIdentifiable?
    
    func onAppear() {
        Task {
            if subscription.isNotNil {
                anytypeAssertionFailure("Try start subscription again")
            }
            subscription?.cancel()
            subscription = await notificationSubscriptionService.addHandler { [weak self] events in
                await self?.handle(events: events)
            }
        }
    }
    
    func onDisappear() {
        subscription?.cancel()
        subscription = nil
    }
    
    // MARK: - Private
    
    private func handle(events: [NotificationEvent]) async {
        for event in events {
            switch event {
            case .send(let notification):
                handleSend(notification: notification)
            case .update:
                continue
            }
        }
    }
    
    private func handleSend(notification: Services.Notification) {
        switch notification.payload {
        case .galleryImport(let data):
            let view = GalleryNotificationView(notification: NotificationGalleryImport(common: notification, galleryImport: data))
            show(view: view)
        case .participantPermissionsChange(let data):
            let view = PermissionChangeNotificationView(notification: NotificationParticipantPermissionsChange(common: notification, permissionChange: data))
            show(view: view)
        case .participantRequestApproved(let data):
            let view = ParticipantApproveNotificationView(notification: NotificationParticipantRequestApproved(common: notification, requestApprove: data))
            show(view: view)
        case .participantRequestDecline(let data):
            let view = ParticipantDeclineNotificationView(notification: NotificationParticipantRequestDecline(common: notification, requestDecline: data))
            show(view: view)
        case .requestToLeave(let data):
            let view = RequestToLeaveNotificationView(notification: NotificationRequestToLeave(common: notification, requestToLeave: data))
            show(view: view)
        case .requestToJoin(let data):
            let view = RequestToJoinNotificationView(notification: NotificationRequestToJoin(common: notification, requestToJoin: data))
            show(view: view)
        case .participantRemove(let data):
            let view = ParticipantRemoveNotificationView(
                notification: NotificationParticipantRemove(common: notification, remove: data),
                onDelete: { [weak self] spaceId in
                    self?.spaceIdForDeleteAlert = spaceId.identifiable
                }
            )
            show(view: view)
        case .import, .export, .test, .none:
            // Ignore
            break
        }
    }
    
    private func show<T: View>(view: T) {
        
        let entryName = UUID().uuidString
        
        let containerView = VStack(spacing: 0) {
            view
            Spacer()
        }
        .frame(height: 200)
        .environment(\.notificationDismiss, {
            SwiftEntryKit.dismiss(.specific(entryName: entryName))
        })
        // Max height. SwiftEntryKit can't handle swiftui view height.
        // This is 🩼. Migrate to swiftui scene and add swiftui window for alerts.
        
        var attributes = EKAttributes()
        
        attributes.name = entryName
        attributes.windowLevel = .alerts
        attributes.displayDuration = 4
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.position = .top
        
        let controller = UIHostingController(rootView: containerView)
        controller.view.backgroundColor = .clear
        SwiftEntryKit.display(entry: controller.view, using: attributes)
    }
}
