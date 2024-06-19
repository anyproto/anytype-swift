import UIKit
import SwiftUI
import AnytypeCore
import DeepLinks

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: QuickActionShortcutBuilderProtocol
    
    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.shortcutItems = quickActionShortcutBuilder.buildShortcutItems()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = quickActionShortcutBuilder.buildAction(shortcutItem: item) else { return false }
        
        appActionStorage.action = action.toAppAction()
        return true
    }
}
