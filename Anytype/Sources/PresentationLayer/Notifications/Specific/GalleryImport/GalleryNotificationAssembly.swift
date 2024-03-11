import Foundation
import Services
import SwiftUI

@MainActor
protocol GalleryNotificationAssemblyProtocol: AnyObject {
    func make(notification: NotificationGalleryImport) -> AnyView
}

@MainActor
final class GalleryNotificationAssembly: GalleryNotificationAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(notification: NotificationGalleryImport) -> AnyView {
        GalleryNotificationView(
            model: GalleryNotificationViewModel(
                notification: notification,
                notificationSubscriptionService: self.serviceLocator.notificationSubscriptionService(),
                workspaceStorage: self.serviceLocator.workspaceStorage(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage()
            )
        ).eraseToAnyView()
    }
}
