import Foundation

@objc protocol SceneStateListener: AnyObject {
    func willEnterForeground()
    func didEnterBackground()
}
