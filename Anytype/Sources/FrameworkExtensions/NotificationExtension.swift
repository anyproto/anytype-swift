import Foundation
import CoreFoundation
import UIKit

extension Notification.Name {
    static let middlewareEvent = Notification.Name("newMiddlewareEvent")
    
    static let editorCollectionContentOffsetChangeNotification = Notification.Name(
        "EditorCollectionContentOffsetChangeNotification"
    )
    
}
