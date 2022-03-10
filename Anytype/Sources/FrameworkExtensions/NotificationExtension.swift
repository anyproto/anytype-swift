import Foundation
import CoreFoundation
import UIKit

extension Notification.Name {
    static let middlewareEvent = Notification.Name("newMiddlewareEvent")
    
    static let editorCollectionContentOffsetChangeNotification = Notification.Name(
        "EditorCollectionContentOffsetChangeNotification"
    )
    
}

extension Notification {

    func localKeyboardRect(for key: String) -> CGRect? {
        guard let isLocal = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber, isLocal.boolValue else {
            return nil
        }
        guard let frameValue = userInfo?[key] as? NSValue else {
            return nil
        }
        return frameValue.cgRectValue
    }
    
}
