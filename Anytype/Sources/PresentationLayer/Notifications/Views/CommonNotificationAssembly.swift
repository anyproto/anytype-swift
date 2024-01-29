import Foundation
import Services
import SwiftUI

@MainActor
protocol CommonNotificationAssemblyProtocol: AnyObject {
    func make(notification: Services.Notification) -> AnyView
}

@MainActor
final class CommonNotificationAssembly: CommonNotificationAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(notification: Services.Notification) -> AnyView {
        CommonNotificationView(
            model: CommonNotificationViewModel(notification: notification, notificationSubscriptionService: self.serviceLocator.notificationSubscriptionService())
        ).eraseToAnyView()
    }
}
