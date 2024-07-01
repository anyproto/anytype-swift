import Foundation
import AnytypeCore

final class GlobalServicesConfiguration: AppConfiguratorProtocol {
    
    @Injected(\.middlewareEventsListener)
    private var eventListener: MiddlewareEventsListenerProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: any AccountEventHandlerProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: any FileErrorEventHandlerProtocol
    @Injected(\.deviceSceneStateListener)
    private var deviceSceneStateListener: any DeviceSceneStateListenerProtocol
    @Injected(\.appVersionService)
    private var appVersionService: any AppVersionServiceProtocol
    
    func configure() {
        // Global listeners
        eventListener.startListening()
        accountEventHandler.startSubscription()
        fileErrorEventHandler.startSubscription()
        deviceSceneStateListener.start()
        appVersionService.prepareData()
    }
}
