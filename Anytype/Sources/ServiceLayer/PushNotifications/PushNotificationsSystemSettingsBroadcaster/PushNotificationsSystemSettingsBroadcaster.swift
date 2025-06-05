import UIKit
import UserNotifications
import AsyncTools
import AnytypeCore

protocol PushNotificationsSystemSettingsBroadcasterProtocol: AnyObject, Sendable {
    var statusStream: AnyAsyncSequence<PushNotificationsPermissionStatus> { get }
}

final class PushNotificationsSystemSettingsBroadcaster: PushNotificationsSystemSettingsBroadcasterProtocol, @unchecked Sendable {
    
    var statusStream: AnyAsyncSequence<PushNotificationsPermissionStatus> {
        statusStreamInternal.eraseToAnyAsyncSequence()
    }
    
    private let statusStreamInternal = AsyncToManyStream<PushNotificationsPermissionStatus>()
    
    private let pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol = Container.shared.pushNotificationsPermissionService()
    
    @UserDefault("UserData.PushNotifications.LastStatus", defaultValue: nil)
    private var lastStatus: PushNotificationsPermissionStatus?
    
    private var didBecomeActiveObserver: NotificationCancellable?
    
    init() {
        Task { await setInitialStatus() }
        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.fetchAndSendIfChanged()
            }
        }
        .notificationCancellable()
    }
    
    private func setInitialStatus() async {
        let currentStatus = await pushNotificationsPermissionService.authorizationStatus()
        lastStatus = currentStatus
        statusStreamInternal.send(currentStatus)
    }
    
    private func fetchAndSendIfChanged() async {
        let currentStatus = await pushNotificationsPermissionService.authorizationStatus()
        
        if currentStatus != lastStatus {
            lastStatus = currentStatus
            statusStreamInternal.send(currentStatus)
        }
    }
}
