import Foundation
import Services
import Combine
import AnytypeCore
import SwiftEntryKit
import SwiftUI

protocol NotificationCoordinatorProtocol {
    func startHandle() async
    func stopHandle()
}

// TODO: Rename to Coordinator
final class NotificationCoordinator: NotificationCoordinatorProtocol {
    
    private let notificationSubscriptionService: NotificationsSubscriptionServiceProtocol
    // Specific View
    private let commonNotificationAssembly: CommonNotificationAssemblyProtocol
    
    private var subscription: AnyCancellable?
    
    init(
        notificationSubscriptionService: NotificationsSubscriptionServiceProtocol,
        commonNotificationAssembly: CommonNotificationAssemblyProtocol
    ) {
        self.notificationSubscriptionService = notificationSubscriptionService
        self.commonNotificationAssembly = commonNotificationAssembly
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
        case .import, .export, .galleryImport:
            let view = commonNotificationAssembly.make(notification: notification)
            show(view: view)
        case .none:
            break
        }
    }
    
    @MainActor
    func show(view: AnyView) {
        var attributes = EKAttributes()
        
        attributes.windowLevel = .alerts
        attributes.displayDuration = 4
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.position = .top
        
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        SwiftEntryKit.display(entry: controller.view, using: attributes)
    }
}
