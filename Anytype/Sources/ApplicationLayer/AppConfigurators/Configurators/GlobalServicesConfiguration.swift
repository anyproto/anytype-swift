import Foundation
import AnytypeCore
import Services

final class GlobalServicesConfiguration: AppConfiguratorProtocol {
    
    @Injected(\.middlewareEventsListener)
    private var eventListener: any MiddlewareEventsListenerProtocol
    @Injected(\.accountEventHandler)
    private var accountEventHandler: any AccountEventHandlerProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: any FileErrorEventHandlerProtocol
    @Injected(\.deviceSceneStateListener)
    private var deviceSceneStateListener: any DeviceSceneStateListenerProtocol
    @Injected(\.appVersionUpdateService)
    private var appVersionUpdateService: any AppVersionUpdateServiceProtocol
    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    
    func configure() {
        // Global listeners
        eventListener.startListening()
        Task {
            await accountEventHandler.startSubscription()
            await fileErrorEventHandler.startSubscription()
        }
        deviceSceneStateListener.start()
        appVersionUpdateService.prepareData()
        debugService.startDebugRunProfilerOnStartupIfNeeded()
    }
}
