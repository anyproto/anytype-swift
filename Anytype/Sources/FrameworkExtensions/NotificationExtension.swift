import Foundation

extension Notification.Name {
    static let middlewareEvent = Notification.Name("newMiddlewareEvent")
    
    static let documentIconImageUploadingEvent = Notification.Name(
        "DocumentIconImageUploadingEvent"
    )
    
    static let documentCoverImageUploadingEvent = Notification.Name(
        "DocumentCoverImageUploadingEvent"
    )
    
}
