import Foundation
import Services
import Combine
import AnytypeCore
import SwiftEntryKit
import SwiftUI

protocol NotificationCoordinatorProtocol: AnyObject {
    func startHandle() async
    func stopHandle()
}

final class NotificationCoordinator: NotificationCoordinatorProtocol {
    
    private let notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    // Common for show notifications without specific logic and buttons
    private let commonNotificationAssembly: CommonNotificationAssemblyProtocol
    // Specific View
    private let galleryNotificationAssembly: GalleryNotificationAssemblyProtocol
    
    private var subscription: AnyCancellable?
    
    init(
        notificationSubscriptionService: NotificationsSubscriptionServiceProtocol,
        commonNotificationAssembly: CommonNotificationAssemblyProtocol,
        galleryNotificationAssembly: GalleryNotificationAssemblyProtocol
    ) {
        self.notificationSubscriptionService = notificationSubscriptionService
        self.commonNotificationAssembly = commonNotificationAssembly
        self.galleryNotificationAssembly = galleryNotificationAssembly
    }
    
    func startHandle() async {
        if subscription.isNotNil {
            anytypeAssertionFailure("Try start subscription again")
        }
        subscription?.cancel()
        subscription = await notificationSubscriptionService.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func stopHandle() {
        subscription?.cancel()
        subscription = nil
    }
    
    private func handle(events: [NotificationEvent]) async {
        for event in events {
            switch event {
            case .send(let notification):
                await handleSend(notification: notification)
            case .update:
                continue
            }
        }
    }
    
    @MainActor
    private func handleSend(notification: Services.Notification) {
        switch notification.payload {
        case .galleryImport(let data):
            let view = galleryNotificationAssembly.make(notification: NotificationGalleryImport(common: notification, galleryImport: data))
            show(view: view)
        default:
            break
        }
    }
    
    @MainActor
    func show(view: AnyView) {
        
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
