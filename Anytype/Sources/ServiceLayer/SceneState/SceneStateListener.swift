import Foundation

@objc protocol SceneStateListener: AnyObject {
    @MainActor
    func willEnterForeground()
    @MainActor
    func didEnterBackground()
}
